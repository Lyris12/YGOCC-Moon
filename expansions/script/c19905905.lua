--MMS - Tagliatore
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:Ignition(0,CATEGORY_SPECIAL_SUMMON,nil,LOCATION_HAND+LOCATION_REMOVED,true,
		nil,
		aux.BanishCost(aux.MonsterFilter(Card.IsSetCard,0xd71),LOCATION_HAND+LOCATION_GRAVE,0,1,1,true),
		aux.SSTarget(SUBJECT_THIS_CARD),
		aux.SSOperation(SUBJECT_THIS_CARD)
	)
	--tohand
	c:Ignition(1,CATEGORY_TOHAND+CATEGORY_SEARCH,EFFECT_FLAG_CARD_TARGET,LOCATION_MZONE,true,
		nil,
		nil,
		aux.Target(s.filter,LOCATION_ONFIELD,0,1,1,nil,s.check,CATEGORY_TOHAND,nil,nil,aux.Info(CATEGORY_TOHAND,1,0,LOCATION_DECK)),
		aux.CreateOperation(
			aux.SendToHandOperation(SUBJECT_IT),
			CONJUNCTION_AND_IF_YOU_DO,
			aux.SearchOperation(s.thfilter,LOCATION_DECK+LOCATION_GRAVE)
		)
	)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSpellTrapOnField() and c:IsSetCard(0xd71) and c:IsAbleToHand()
end
function s.thfilter(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end
function s.check(e,tp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end