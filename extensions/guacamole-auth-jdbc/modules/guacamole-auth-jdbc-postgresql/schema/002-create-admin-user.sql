--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.
--

-- Create default user "toystackadmin" with password "toystackadmin"
INSERT INTO guacamole_entity (name, type) VALUES ('toystackadmin', 'USER');
INSERT INTO guacamole_user (entity_id, password_hash, password_salt, password_date)
SELECT
    entity_id,
    decode('5a23b2ee97032a7f0e1bc724653cbb188329dce94d8cc455f78a2a2dc76f4d58', 'hex'),  -- 'toystackadmin'
    decode('c9de5ea6b93b56a8c6cf8ab5c1326113589d6ce0bd4901daf2415909ae5a1d7e', 'hex'),
    CURRENT_TIMESTAMP
FROM guacamole_entity WHERE name = 'toystackadmin' AND guacamole_entity.type = 'USER';

-- Grant this user all system permissions
INSERT INTO guacamole_system_permission (entity_id, permission)
SELECT entity_id, permission::guacamole_system_permission_type
FROM (
    VALUES
        ('toystackadmin', 'CREATE_CONNECTION'),
        ('toystackadmin', 'CREATE_CONNECTION_GROUP'),
        ('toystackadmin', 'CREATE_SHARING_PROFILE'),
        ('toystackadmin', 'CREATE_USER'),
        ('toystackadmin', 'CREATE_USER_GROUP'),
        ('toystackadmin', 'ADMINISTER')
) permissions (username, permission)
JOIN guacamole_entity ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER';

-- Grant admin permission to read/update/administer self
INSERT INTO guacamole_user_permission (entity_id, affected_user_id, permission)
SELECT guacamole_entity.entity_id, guacamole_user.user_id, permission::guacamole_object_permission_type
FROM (
    VALUES
        ('toystackadmin', 'toystackadmin', 'READ'),
        ('toystackadmin', 'toystackadmin', 'UPDATE'),
        ('toystackadmin', 'toystackadmin', 'ADMINISTER')
) permissions (username, affected_username, permission)
JOIN guacamole_entity          ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER'
JOIN guacamole_entity affected ON permissions.affected_username = affected.name AND guacamole_entity.type = 'USER'
JOIN guacamole_user            ON guacamole_user.entity_id = affected.entity_id;
