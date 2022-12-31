--Devil Shogun, Great Past Six Samurai Leader
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
		--XYZ by a different way
		c:EnableReviveLimit()
		aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x3d),5,3)
		--special summon condition
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_CONDITION)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		c:RegisterEffect(e1)
		Duel.AddCustomActivityCounter(300010,ACTIVITY_SPSUMMON,s.counterfilter2)
		--Special Summon
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_SPSUMMON_PROC)
		e2:SetRange(LOCATION_EXTRA)
		e2:SetCondition(s.spcon)
		e2:SetOperation(s.spop)
		c:RegisterEffect(e2)
		--boost attack
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetCategory(CATEGORY_ATKCHANGE)
		e3:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
		e3:SetCountLimit(1,id+500)
		e3:SetCost(s.rost)
		e3:SetOperation(s.pop)
		c:RegisterEffect(e3)
		-- trg and destroy
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,2))
		e4:SetCategory(CATEGORY_DESTROY)
		e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e4:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCountLimit(1,id+1000)
		e4:SetCode(EVENT_FREE_CHAIN)
		e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
		e4:SetCost(s.thcost)
		e4:SetTarget(s.thtg)
		e4:SetOperation(s.thop)
		c:RegisterEffect(e4)
end
	function s.counterfilter2(c)
	return c:IsRace(RACE_WARRIOR)
end
	function s.cfilter(c)
	return c:IsCode(63176202) and c:IsFaceup()
end
	function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetCustomActivityCount(300010,tp,ACTIVITY_SPSUMMON)==0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
	function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local sg=tc:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	c:SetMaterial(Group.FromCards(sg))
	Duel.Overlay(c,Group.FromCards(sg))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
end
	function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_WARRIOR)
end
	function s.rfilter(c)
	return c:IsSetCard(0x3d) and c:GetBaseAttack()>0 and c:IsAbleToRemoveAsCost()
end
	function s.rost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetBaseAttack())
end
	function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
	function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
	function s.yfilter(c)
	return c:IsSetCard(0x3d) and c:IsType(TYPE_MONSTER)
end
	function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local o=Duel.GetMatchingGroup(s.yfilter,tp,LOCATION_REMOVED,0,nil)
	local ct=o:GetClassCount(Card.GetAttribute)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
	function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end