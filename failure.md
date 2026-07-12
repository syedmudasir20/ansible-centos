# changes in failure.yml

## failure.yml
```
---
- name: Task Failure lab
  hosts: ansible-node1
  vars:
    web_package: http
    db_package: mariadb-server
    db_service: mariadb

  tasks:
    - name: Install {{ web_package }} package
      dnf:
        name: "{{ web_package }}"
        state: present

    - name: Install {{ db_package }} package
      dnf:
        name: "{{ db_package }}"
        state: present
```

## adding ignore block
```
- name: Task Failure lab
  hosts: ansible-node1
  vars:
    web_package: http
    db_package: mariadb-server
    db_service: mariadb
  tasks:
    - name: Install {{ web_package }} package
      dnf:
        name: "{{ web_package }}"
        state: present
      ignore_errors: yes
    - name: Install {{ db_package }} package
      dnf:
        name: "{{ db_package }}"
        state: present
```

## adding block task
```
---
- name: Task Failure lab
  hosts: ansible-node1
  vars:
    web_package: http
    db_package: mariadb-server
    db_service: mariadb
  tasks:
    - name: Install {{ web_package }} package
      block:
        - name: Install {{ web_package }} package
          yum:
            name: "{{ web_package }}"
            state: present
      rescue:
        - name: Install {{ de_package }} package
          yum:
            name: "{{ db_package }}"
            state: present
      always:
        - name: strat {{ db_service }}
          service:
            name: "{{ db_service }}"
            state: started
```

## using correct package name
```
---
- name: Task Failure lab
  hosts: ansible-node1
  vars:
    web_package: httpd
    db_package: mariadb-server
    db_service: mariadb
  tasks:
    - name: Attempt to set up a webserver
      block:
        - name: Install {{ web_package }} package
          yum:
            name: "{{ web_package }}"
            state: present
      rescue:
        - name: Install {{ de_package }} package
          yum:
            name: "{{ db_package }}"
            state: present
      always:
        - name: strat {{ db_service }}
          service:
            name: "{{ db_service }}"
            state: started
```

## with two extra tasks
```
---
- name: Task Failure lab
  hosts: ansible-node1
  vars:
    web_package: httpd
    db_package: mariadb-server
    db_service: mariadb
  tasks:
    - name: check the local time
      command: date
      register: command_result
    - name: print local time
      debug:
        var: command_result.stdout
    - name: Attempt to set up a webserver
      block:
        - name: Install {{ web_package }} package
          yum:
            name: "{{ web_package }}"
            state: present
      rescue:
        - name: Install {{ de_package }} package
          yum:
            name: "{{ db_package }}"
            state: present
      always:
        - name: strat {{ db_service }}
          service:
            name: "{{ db_service }}"
            state: started
```

## with surpass change in task1
```
---
- name: Task Failure lab
  hosts: ansible-node1
  vars:
    web_package: httpd
    db_package: mariadb-server
    db_service: mariadb
  tasks:
    - name: check the local time
      command: date
      register: command_result
      changed_when: false
    - name: print local time
      debug:
        var: command_result.stdout
    - name: Attempt to set up a webserver
      block:
        - name: Install {{ web_package }} package
          yum:
            name: "{{ web_package }}"
            state: present
      rescue:
        - name: Install {{ de_package }} package
          yum:
            name: "{{ db_package }}"
            state: present
      always:
        - name: strat {{ db_service }}
          service:
            name: "{{ db_service }}"
            state: started
```
