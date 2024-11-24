--Magical Magicalia's Mana Gemstone
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a "Magicalia" monster.
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x722))
	--The equipped monster gains 300 ATK/DEF for each banished "Magicalia" card, also it can attack all monsters your opponent controls, once each.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--If this card is sent to the GY: You can target up to 3 of your "Magicalia" cards that are banished and/or in your GY, except "Magical Magicalia's Mana Gemstone"; shuffle them into the Deck. and if you do, gain 300 LP for each returned card.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.shuffletg)
	e3:SetOperation(s.shuffleop)
	c:RegisterEffect(e3)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_REMOVED,0,nil,0x722)*300
end
function s.filter(c)
	return c:IsSetCard(0x722) and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.shuffletg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,#g*300)
end
function s.shuffleop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		Duel.Recover(tp,ct*300,REASON_EFFECT)
	end
end