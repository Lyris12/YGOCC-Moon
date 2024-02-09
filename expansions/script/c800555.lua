--Mecha Phantom Beast Zduheed
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
		c:SetUniqueOnField(1,0,800555)
		--synchro summon
		aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x101b),aux.NonTuner(nil),1)
		c:EnableReviveLimit()
		--absolute proc
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.indtg)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
		-- cannot be ef trg
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(s.indtg)
		e3:SetValue(aux.tgoval)
		c:RegisterEffect(e3)
		--D&B
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,0))
		e4:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e4:SetCode(EVENT_FREE_CHAIN)
		e4:SetRange(LOCATION_MZONE)
		e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
		e4:SetCountLimit(1)
		e4:SetCost(s.descost)
		e4:SetTarget(s.destg)
		e4:SetOperation(s.desop)
		c:RegisterEffect(e4)
		--place on top
		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,1))
		e5:SetCategory(CATEGORY_TODECK)
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e5:SetCode(EVENT_TO_GRAVE)
		e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		e5:SetCondition(s.tdcon)
		e5:SetTarget(s.tdtg)
		e5:SetOperation(s.tdop)
		c:RegisterEffect(e5)  
end
	function s.indtg(e,c)
	return (c:IsSetCard(0x101b) or c:IsType(TYPE_TOKEN)) and c~=e:GetHandler()
end
	function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
	function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	Duel.Release(g,REASON_COST)
end
	function s.desfilter(c)
	return c:IsAbleToRemove()
end
	function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
	function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
	function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
		and rp==1-tp and c:GetPreviousControler()==tp
end
	function s.floatfilter(c)
	return c:IsAbleToDeck() and c:IsFaceup()
end
	function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:GetControler()==tp and s.floatfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.floatfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectTarget(tp,s.floatfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end 
	function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
	end
end
