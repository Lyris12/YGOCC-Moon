--Rangvald, Cascad Tactician
--Script by XGlitchy30
function c31231304.initial_effect(c)
	--change levels
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34103656,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c31231304.lvtg)
	e1:SetOperation(c31231304.lvop)
	c:RegisterEffect(e1)
	--mill deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31231304,1))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,31231304)
	e2:SetCondition(c31231304.millcon)
	e2:SetTarget(c31231304.milltg)
	e2:SetOperation(c31231304.millop)
	c:RegisterEffect(e2)
end
--filters
function c31231304.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3233) and c:GetLevel()>0
end
function c31231304.lvcount(c)
	return c:IsFaceup() and c:GetLevel()==2
end
--change levels
function c31231304.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31231304.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function c31231304.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local lv=Duel.GetMatchingGroupCount(c31231304.lvcount,tp,LOCATION_MZONE,0,nil)
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		local mg,fid=g:GetMaxGroup(Card.GetFieldID)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c31231304.efftg)
		e1:SetValue(lv)
		e1:SetLabel(fid)
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function c31231304.efftg(e,c)
	return c:GetFieldID()<=e:GetLabel() and c:IsSetCard(0x3233) and c:GetLevel()>0
end
--mill deck
function c31231304.millcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
function c31231304.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3)
		and g:FilterCount(Card.IsAbleToRemove,nil)==3 
	end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end
function c31231304.millop(e,tp,eg,ep,ev,re,r,rp)
	local sd=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local od=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	if sd<=2 or od<=2 then return end
	if sd>=3 then sd=3 end
	Duel.DiscardDeck(tp,sd,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:GetCount()==3 then
		local mill=Duel.GetDecktopGroup(1-tp,g:GetCount())
		Duel.DisableShuffleCheck()
		Duel.Remove(mill,POS_FACEUP,REASON_EFFECT)
	end
end