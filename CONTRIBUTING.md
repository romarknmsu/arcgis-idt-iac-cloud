# Contributing to ArcGIS Enterprise IaC Cloud

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check existing [Issues](https://github.com/romarknmsu/arcgis-idt-iac-cloud/issues) to avoid duplicates
2. Create a new issue with:
   - Clear, descriptive title
   - Detailed description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment details (OS, Terraform version, Ansible version)
   - Relevant logs or error messages

### Submitting Changes

1. **Fork the repository**
   ```bash
   git clone https://github.com/romarknmsu/arcgis-idt-iac-cloud.git
   cd arcgis-idt-iac-cloud
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style and conventions
   - Add comments for complex logic
   - Update documentation if needed

4. **Test your changes**
   - Validate Terraform: `terraform validate`
   - Check Ansible syntax: `ansible-playbook --syntax-check playbook.yml`
   - Test locally if possible
   - Ensure workflows still pass

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add feature: description of your changes"
   ```

6. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Development Guidelines

### Terraform Code

- Use meaningful variable and resource names
- Add descriptions to all variables
- Follow HashiCorp's Terraform style guide
- Use modules for reusable components
- Tag all resources appropriately
- Run `terraform fmt` before committing

### Ansible Code

- Follow YAML best practices
- Use roles for logical grouping
- Make playbooks idempotent
- Add meaningful task names
- Use variables for configuration
- Test on both Linux and Windows when applicable

### GitHub Actions

- Keep workflows DRY (Don't Repeat Yourself)
- Use secrets for sensitive data
- Add descriptive job and step names
- Include error handling
- Use caching where appropriate

### Documentation

- Update README.md for major changes
- Add inline comments for complex logic
- Keep documentation in sync with code
- Use clear, concise language
- Include examples where helpful

## Coding Standards

### General

- Use consistent indentation (2 spaces for YAML, 2 spaces for HCL)
- Keep lines under 100 characters when possible
- Use meaningful names for variables, functions, and resources
- Remove commented-out code before committing
- No hardcoded credentials or secrets

### Terraform

```hcl
# Good
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = {
    Name = "${var.project_name}-web-server"
  }
}

# Bad
resource "aws_instance" "i" {
  ami = "ami-12345678"
  instance_type = "t2.micro"
}
```

### Ansible

```yaml
# Good
- name: Install required packages
  yum:
    name:
      - package1
      - package2
    state: present

# Bad
- yum: name=package1,package2 state=present
```

## Testing

### Before Submitting

1. **Terraform Validation**
   ```bash
   cd terraform
   terraform fmt -recursive
   terraform init -backend=false
   terraform validate
   ```

2. **Ansible Syntax Check**
   ```bash
   cd ansible
   ansible-playbook --syntax-check playbook-linux.yml
   ansible-playbook --syntax-check playbook-windows.yml
   ```

3. **YAML Validation**
   ```bash
   yamllint .github/workflows/*.yml
   ```

### Manual Testing

If possible, test your changes:
- Deploy infrastructure with your changes
- Verify all components work as expected
- Check logs for errors or warnings
- Test both creation and destruction
- Verify cleanup is complete

## Pull Request Process

1. **Update Documentation**
   - Update README.md if needed
   - Add comments to complex code
   - Update CHANGELOG.md if you're adding one

2. **Describe Your Changes**
   - Clear PR title
   - Detailed description of changes
   - Link related issues
   - Add screenshots for UI changes
   - List any breaking changes

3. **Review Process**
   - Maintainers will review your PR
   - Address feedback and comments
   - Make requested changes
   - Keep PR focused and small

4. **Merging**
   - PRs require approval from maintainers
   - All tests must pass
   - Conflicts must be resolved
   - Commits may be squashed

## Project Structure

```
├── terraform/           # Infrastructure as Code
│   ├── modules/        # Reusable Terraform modules
│   └── environments/   # Environment-specific configs
├── ansible/            # Configuration management
│   ├── roles/         # Ansible roles
│   └── inventories/   # Inventory files
├── .github/           # GitHub Actions workflows
│   └── workflows/     # CI/CD workflows
└── docs/              # Documentation
```

## Commit Message Guidelines

Use clear, descriptive commit messages:

```
Good:
- "Add EKS cluster monitoring configuration"
- "Fix Windows certificate generation in Ansible"
- "Update README with new prerequisites"

Bad:
- "fix bug"
- "update"
- "changes"
```

Format:
```
<type>: <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## Security

- Never commit credentials or secrets
- Use GitHub Secrets for sensitive data
- Follow AWS security best practices
- Encrypt data at rest and in transit
- Limit IAM permissions to minimum required
- Report security vulnerabilities privately

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on the code, not the person
- Help others learn and grow

## Questions?

- Open an issue for questions
- Tag with "question" label
- Check existing issues first
- Be specific and clear

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation

Thank you for contributing to ArcGIS Enterprise IaC Cloud! 🎉
