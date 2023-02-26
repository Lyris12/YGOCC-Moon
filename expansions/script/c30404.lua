--Ｚ・ＨＥＲＯ　デビルロード
--Zero HERO Devil Lord
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x8),scard.matfilter,true)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(scard.splimit)
	c:RegisterEffect(e0)
	--atk change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(s_id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(scard.atkcon)
	e1:SetTarget(scard.atktg)
	e1:SetOperation(scard.atkop)
	e1:SetCountLimit(1,s_id)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,RELEVANT_TIMINGS+TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	--disable spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(s_id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(scard.condition)
	e2:SetCost(scard.cost)
	e2:SetTarget(scard.target)
	e2:SetOperation(scard.activate)
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	c:RegisterEffect(e2)
end
function scard.matfilter(c)
	if c:IsFusionSetCard(0x8) and c:IsFusionCustomSetCard(CUSTOM_ARCHE_ZERO_HERO) then
		return true
	end
	local codechk=false
	local codes={c:GetFusionCode()}
	for _,code in ipairs(codes) do
		if code>30400 and code<30420 then
			codechk=true
			break
		end
	end
	return codechk
end

function scard.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end

function scard.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and aux.ExceptOnDamageCalc()
end
function scard.fufilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or (c:GetAttack()>0 or c:GetDefense()>0))
end
function scard.rmfilter(c)
	return c:IsMonster() and c:IsZHERO() and c:IsAbleToRemove()
end
function scard.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(scard.fufilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		return #g>0 and Duel.IsExistingMatchingCard(scard.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,LOCATION_MZONE,{0})
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,1-tp,LOCATION_MZONE,{0})
end
function scard.atkop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(scard.rmfilter),tp,LOCATION_GRAVE,0,nil)
	if sg:GetCount()<1 then return end
	local tg=sg:Select(tp,1,1,nil)
	if #tg>0 and Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g<=0 then return end
		local c=e:GetHandler()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(STRING_CANNOT_TRIGGER)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e2:SetRange(LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e3)
		end
	end
end

function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetAttack()~=c:GetBaseAttack() or c:GetDefense()~=c:GetBaseDefense()
end
function scard.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(scard.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function scard.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function scard.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsControler(1-tp) and tc:IsFaceup() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
