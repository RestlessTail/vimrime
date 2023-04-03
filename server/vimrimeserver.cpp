/*
 * A modification of rime_api_console.cc
 * 2023-04-03 RestlessTail <1826930551@qq.com>
 *
 * Copyright RIME Developers
 * Distributed under the BSD License
 *
 * 2011-08-29 GONG Chen <chen.sst@gmail.com>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <rime_api.h>

void print(RimeSessionId session_id) {
	RimeApi* rime = rime_get_api();

	RIME_STRUCT(RimeCommit, commit);
	RIME_STRUCT(RimeContext, context);

	printf("{\"status\":\"ready\",");
	if (rime->get_commit(session_id, &commit)) {
		printf("\"commit\":\"%s\",", commit.text);
		rime->free_commit(&commit);
	}
	else {
		printf("\"commit\":\"\",");
	}

	if (rime->get_context(session_id, &context) && context.composition.length > 0) {
		printf("\"composition\":{\"preedit\":\"%s\",\"start\":%d,\"end\":%d,\"cursor\":%d},", context.composition.preedit, context.composition.sel_start, context.composition.sel_end, context.composition.cursor_pos);
		printf("\"menu\":{\"highlighted\":%d,\"candidates\":[", context.menu.highlighted_candidate_index);
		for(int i = 0; i < context.menu.num_candidates; ++i){
			printf(",\"%s\"" + (i == 0 ? 1 : 0), context.menu.candidates[i].text);
		}
		printf("]}");
		rime->free_context(&context);
	}
	else {
		printf("\"composition\":\"\",\"menu\":{\"highlighted\":-1,\"candidates\":[]}");
	}
	printf("}\n");
}

bool execute_special_command(const char* line, RimeSessionId session_id) {
	RimeApi* rime = rime_get_api();
	if (!strcmp(line, "list schema")) {
		RimeSchemaList list;
		if (!rime->get_schema_list(&list)) {
			printf("{\"status\":\"failed\",\"message\":\"Error getting schema list.\"}\n");
			return true;
		}
		char current[100] = { 0 };
		if (!rime->get_current_schema(session_id, current, sizeof(current))) {
			printf("{\"status\":\"failed\",\"message\":\"Error getting current schema.\"}\n");
			return true;
		}
		printf("{\"status\":\"ready\",\"schemas\":[");
		for (size_t i = 0; i < list.size; ++i) {
			printf(",{\"name\":\"%s\",\"id\":\"%s\"}" + (i == 0 ? 1 : 0), list.list[i].name, list.list[i].schema_id);
		}
		rime->free_schema_list(&list);
		printf("],\"current\":\"%s\"}\n", current);
		return true;
	}
	const char* kSelectSchemaCommand = "select schema ";
	size_t command_length = strlen(kSelectSchemaCommand);
	if (!strncmp(line, kSelectSchemaCommand, command_length)) {
		const char* schema_id = line + command_length;
		if (rime->select_schema(session_id, schema_id)) {
			printf("{\"status\":\"ready\"}\n");
		}
		return true;
	}
	return false;
}

void on_message(void* context_object,
		RimeSessionId session_id,
		const char* message_type,
		const char* message_value) {
	//printf("message: [%lu] [%s] %s", session_id, message_type, message_value);
}

int main(int argc, char *argv[]) {
	RimeApi* rime = rime_get_api();

	RIME_STRUCT(RimeTraits, traits);
	traits.app_name = "vimrime.server";
	rime->setup(&traits);

	rime->set_notification_handler(&on_message, NULL);
	rime->initialize(NULL);
	Bool full_check = True;
	if (rime->start_maintenance(full_check)){
		rime->join_maintenance_thread();
	}

	RimeSessionId session_id = rime->create_session();
	if (!session_id) {
		printf("{\"status\":\"failed\",\"message\":\"Error creating rime session.\"}\n");
		exit(-1);
	}
	else{
		printf("{\"status\":\"ready\"}\n");
	}

	const int kMaxLength = 99;
	char line[kMaxLength + 1] = {0};
	while (fgets(line, kMaxLength, stdin) != NULL) {
		for (char *p = line; *p; ++p) {
			if (*p == '\r' || *p == '\n') {
				*p = '\0';
				break;
			}
		}
		if (!strcmp(line, "exit"))
			break;
		if (execute_special_command(line, session_id))
			continue;
		if (rime->simulate_key_sequence(session_id, line)) {
			print(session_id);
		} else {
			//fprintf(stderr, "Error processing key sequence: %s\n", line);
		}
	}

	rime->destroy_session(session_id);

	rime->finalize();

	return 0;
}
