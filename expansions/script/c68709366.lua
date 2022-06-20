--HDDNoire
--coded by Concordia, cred senpaizuri3, Radioboy, Kretin, Moon_Burst, Naab and André
function c68709366.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,68709327,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf08),1,true,true)
	aux.AddContactFusionProcedure(c,c68709366.cfilter,LOCATION_ONFIELD,0,aux.tdcfop(c))
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c68709366.splimit)
	c:RegisterEffect(e1)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68709366,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,68709366)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c68709366.destg)
	e3:SetOperation(c68709366.desop)
	c:RegisterEffect(e3)
	--actlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(c68709366.aclimit)
	e4:SetCondition(c68709366.actcon)
	c:RegisterEffect(e4)
	--on leaving field SS 2 Arc. M
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(68709366,3))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCountLimit(1,68719366)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCost(c68709366.sp2cost)
	e5:SetCondition(c68709366.sp2con)
	e5:SetTarget(c68709366.sp2tg)
	e5:SetOperation(c68709366.sp2op)
	c:RegisterEffect(e5)
	Duel.AddCustomActivityCounter(68709366,ACTIVITY_SPSUMMON,c68709366.counterfilter)
end
function c68709366.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c68709366.cfilter(c)
	return (c:IsFusionCode(68709327) or c:IsFusionSetCard(0xf08) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end

function c68709366.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c68709366.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c68709366.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function c68709366.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- on leaving field SS 2 Arc. M
function c68709366.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsSetCard(0xf09)
end
function c68709366.sp2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(68709366,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c68709366.sp2limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c68709366.sp2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xf09)
end
function c68709366.filter1(c,e,tp)
	return c:IsSetCard(0xf08) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c68709366.filter2(c,g)
	return g:IsExists(c68709366.filter3,1,c,c:GetCode())
end
function c68709366.filter3(c,code)
	return not c:IsCode(code)
end
function c68709366.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		local g=Duel.GetMatchingGroup(c68709366.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:IsExists(c68709366.filter2,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c68709366.sp2op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(c68709366.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	local dg=g:Filter(c68709366.filter2,nil,g)
	if dg:GetCount()>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=dg:Select(tp,1,1,nil)
		local tc1=sg:GetFirst()
		dg:Remove(Card.IsCode,nil,tc1:GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc2=dg:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
		local g=Group.FromCards(tc1,tc2)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c68709366.sp2limit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xf09)
end