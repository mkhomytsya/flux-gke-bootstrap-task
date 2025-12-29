# Налаштування за замовчуванням
TF_DIR = bootstrap

.PHONY: help install init apply destroy vars clean

help:
	@echo "Доступні команди:"
	@echo "  install         - Встановити необхідні інструменти (Tofu, K9s, Flux CLI)"
	@echo "  vars            - Налаштувати змінні GitHub (створює terraform.tfvars)"
	@echo "  init            - Ініціалізувати OpenTofu"
	@echo "  apply           - Запустити розгортання інфраструктури"
	@echo "  bootstrap       - Повний цикл: install -> init -> vars -> apply"
	@echo "  destroy         - Видалити всю створену інфраструктуру"
	@echo "  clean           - Видалити тимчасові файли Tofu та секрети"

install:
	@echo "Встановлення інструментів..."
	@curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone
	@curl -sS https://webi.sh/k9s | bash
	@curl -sS https://fluxcd.io/install.sh | bash
	@echo "Інструменти встановлено. Перезапустіть термінал або додайте шляхи до PATH."

vars:
	@echo "Налаштування змінних GitHub..."
	@read -p "Enter GitHub Organization/User: " github_org; \
	 read -p "Enter GitHub Repository Name: " github_repo; \
	 read -s -p "Enter GitHub Token: " github_token; \
	 echo ""; \
	 echo "github_org = \"$$github_org\"" > $(TF_DIR)/terraform.tfvars; \
	 echo "github_repository = \"$$github_repo\"" >> $(TF_DIR)/terraform.tfvars; \
	 echo "github_token = \"$$github_token\"" >> $(TF_DIR)/terraform.tfvars; \
	 echo "Файл $(TF_DIR)/terraform.tfvars створено."

init:
	@echo "Ініціалізація OpenTofu..."
	@cd $(TF_DIR) && tofu init

apply:
	@echo "Розгортання інфраструктури..."
	@cd $(TF_DIR) && tofu apply -auto-approve
	@echo "Розгортання завершено. Перевірте кластер за допомогою 'k9s'."

bootstrap: install init vars apply
	@echo "Весь процес бутстрапу завершено успішно!"

destroy:
	@echo "Видалення інфраструктури..."
	@cd $(TF_DIR) && tofu destroy -auto-approve

clean:
	@echo "Очищення тимчасових файлів..."
	@rm -rf $(TF_DIR)/.terraform $(TF_DIR)/.terraform.lock.hcl $(TF_DIR)/terraform.tfstate* $(TF_DIR)/terraform.tfvars
	@echo "Очищено."

# Допоміжна команда для аліасів (виводиться текстом, бо аліаси не працюють всередині make)
aliases:
	@echo "Додайте ці рядки до вашого ~/.bashrc або ~/.zshrc:"
	@echo 'alias k="kubectl"'
	@echo 'alias kk="k9s"'
	@echo 'alias tf="tofu"'