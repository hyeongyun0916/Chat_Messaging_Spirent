package com.hg.chat.store.persistence;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;

import com.hg.chat.store.domain.Item;
import com.hg.chat.store.domain.ItemRepository;

public class JpaItemRepository {
	private EntityManagerFactory entityManagerFactory;

	public void setEntityManagerFactory(EntityManagerFactory emf) {
		this.entityManagerFactory = emf;
	}

	@Override
	public Item findById(Integer itemId) {
		EntityManager entityManager = entityManagerFactory.createEntityManager();
		entityManager.joinTransaction();
		return entityManager.find(Item.class, itemId);
	}
}