--created & coded by Lyris, art by Dino-master of DeviantArt
--銀河眼の固体光子竜
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cid.spcon)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetTarget(cid.tg)
	e3:SetOperation(cid.op)
	c:RegisterEffect(e3)
end
function cid.rfilter(c,tp)
	return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
function cid.spcfilter(c)
	return c:IsFaceup() and c:IsCode(93717133) and c:GetEquipGroup():IsExists(aux.AND(Card.IsFaceup,Card.IsCode),1,nil,id)
end
function cid.spgoal(g)
	return g:IsExists(cid.spcfilter,1,nil) and Duel.GetMZoneCount(tp,g)>0
end
function cid.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and Duel.GetReleaseGroup(tp):Filter(cid.rfilter,nil,tp):CheckSubGroup(cid.spgoal,2,2)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.GetReleaseGroup(tp):Filter(cid.rfilter,nil,tp):SelectSubGroup(tp,cid.spgoal,Duel.IsSummonCancelable(),2,2)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else return false end
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,5)
	g:DeleteGroup()
end
function cid.filter(c)
	return c:GetMaterialCount()>0 and c:GetSummonLocation()==LOCATION_EXTRA
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e2:SetValue(aux.TargetBoolFunction(Effect.IsActiveType,TYPE_SPELL))
	c:RegisterEffect(e2)
	local e1=e2:Clone()
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	e1:SetValue(Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst():GetMaterialCount()*500)
	c:RegisterEffect(e1)
end
function cid.eqfilter(c,tp)
	return c:IsCode(68540058) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x107b) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not sc or Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)==0 or not sc:IsCanBeEffectTarget()
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,cid.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	local te=tc:GetActivateEffect()
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	local operation=te:GetOperation()
	if te:IsActivatable(tp,true) and sc:IsCanBeEffectTarget(te)
		and (not condition or condition(te,tp,eg,ep,ev,re,r,rp))
		and (not cost or cost(te,tp,eg,ep,ev,re,r,rp,0)) then
		Duel.ClearTargetCard()
		e:SetProperty(te:GetProperty())
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		tc:CreateEffectRelation(te)
		if cost then cost(te,tp,eg,ep,ev,re,r,rp,1) end
		Duel.SetTargetCard(sc)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for tg in aux.Next(g) do tg:CreateEffectRelation(te) end
		if operation then operation(te,tp,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		for tg in aux.Next(g) do tg:ReleaseEffectRelation(te) end
	end
end
