# Contributing to ArcGIS Enterprise IaC

Thank you for your interest in contributing to this project! We welcome contributions from the community.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:
1. Check if the issue already exists
2. Open a new issue with a clear title and description
3. Include relevant details:
   - Operating system (Windows/Linux distribution)
   - Ansible version
   - Error messages or logs
   - Steps to reproduce

### Submitting Changes

1. Fork the repository
2. Create a new branch for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes following the coding standards below
4. Test your changes thoroughly
5. Commit your changes with clear, descriptive messages
6. Push to your fork
7. Submit a pull request

### Coding Standards

#### Ansible Playbooks and Roles

- Use YAML syntax with 2-space indentation
- Follow [Ansible best practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- Add comments for complex tasks
- Use descriptive task names
- Use variables instead of hard-coded values
- Keep tasks idempotent

Example:
```yaml
- name: Install required package
  ansible.builtin.package:
    name: "{{ package_name }}"
    state: present
```

#### Variable Naming

- Use lowercase with underscores: `arcgis_user`, `min_ram_gb`
- Prefix role-specific variables: `arcgis_prerequisites_*`
- Use descriptive names that explain purpose

#### Documentation

- Update README.md for significant changes
- Add comments in playbooks/roles for complex logic
- Include examples in documentation

### Testing

Before submitting:
1. Run syntax check:
   ```bash
   ansible-playbook --syntax-check <playbook>.yml
   ```
2. Test in a clean environment (VM or container)
3. Verify on both Windows and Linux if applicable
4. Check that all tasks are idempotent (can run multiple times)

### Commit Messages

Use clear, descriptive commit messages:
- Start with a verb in present tense: "Add", "Fix", "Update"
- Keep the first line under 50 characters
- Add detailed description if needed

Examples:
```
Add Ubuntu 24.04 support to Linux role

Fix Windows firewall rule configuration
- Corrected port numbers for ArcGIS Server
- Added description for each rule
```

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn and grow

## Questions?

Open an issue for any questions about contributing.

Thank you for contributing!
