--Evolution-Knight of Synchron
function c249000714.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18036057,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c249000714.condition2)
	e2:SetTarget(c249000714.target2)
	e2:SetOperation(c249000714.operation2)
	c:RegisterEffect(e2)
	--tuner
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c249000714.tunercon)
	e3:SetTarget(c249000714.tunertg)
	e3:SetOperation(c249000714.tunerop)
	c:RegisterEffect(e3)
	--synchro summon
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE+LOCATION_EXTRA)
	e6:SetCondition(c249000714.condition)
	e6:SetCost(c249000714.cost)
	e6:SetTarget(c249000714.target)
	e6:SetOperation(c249000714.operation)
	c:RegisterEffect(e6)
end
function c249000714.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function c249000714.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249000714.operation2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c249000714.confilter(c,e) 
	return c:IsSetCard(0x1E9) and c:GetCode()~=e:GetHandler():GetCode()
end
function c249000714.tunercon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000714.confilter,tp,LOCATION_ONFIELD,0,1,nil,e)
end
function c249000714.tunertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function c249000714.tunerop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and e:GetHandler():IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
function c249000714.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c249000714.costfilter(c)
	return c:IsSetCard(0x1E9) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function c249000714.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c249000714.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,c)
		and c:IsAbleToRemoveAsCost() end
	local g=Duel.SelectMatchingCard(tp,c249000714.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,c)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000714.filter1(c,e,tp)
	return Duel.IsExistingMatchingCard(c249000714.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRace())
end
function c249000714.filter2(c,e,tp,rc)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(5) and c:IsRace(rc) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function c249000714.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c249000714.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingTarget(c249000714.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249000714.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_EXTRA)
end
function c249000714.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000714.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRace())
	local sc=g:GetFirst()
	if sc then
		Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(c249000714.op2)
		e1:SetReset(RESET_EVENT)
		sc:RegisterEffect(e1)
	end
end
function c249000714.filter3(c,rc,lv)
	return c:IsType(TYPE_SYNCHRO) and (c:GetLevel()==lv or c:GetLevel()==lv+1) and c:IsRace(rc)
end
function c249000714.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsReason(REASON_BATTLE) and not (rp == 1-tp and c:IsReason(REASON_EFFECT)) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c249000714.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local tg=Duel.SelectMatchingCard(tp,c249000714.filter3,tp,LOCATION_EXTRA,0,1,1,nil,c:GetRace(),c:GetLevel()+1)
	local tc=tg:GetFirst()
	if tc ~= nil then
		local code=tc:GetCode()
		Duel.ConfirmCards(1-tp,tc)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_EVENT+RESET_PHASE+PHASE_STANDBY)
		e2:SetLabel(code)
		e2:SetOperation(c249000714.spop)
		Duel.RegisterEffect(e2,tp)
	end
	e:Reset()
end
function c249000714.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
function c249000714.filter4(c,e,tp)
	return c:GetCode()==e:GetLabel() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function c249000714.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(c249000714.filter4,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
		local tc=Duel.SelectMatchingCard(tp,c249000714.filter4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetOperation(c249000714.op2)
			e1:SetReset(RESET_EVENT+0x4020000)
			tc:RegisterEffect(e1)
		end
	end
end