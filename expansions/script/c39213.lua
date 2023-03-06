--Junkdust Dragon
--Automate ID

local scard,s_id=GetID()
function scard.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xa3,0x43),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--Change name
	aux.EnableChangeCode(c,CARD_STARDUST_DRAGON,LOCATION_MZONE+LOCATION_GRAVE)
	--Reduce ATK
	aux.RegisterMergedDelayedEventGlitchy(c,s_id,EVENT_SPSUMMON_SUCCESS,scard.cfilter,s_id+200,LOCATION_MZONE)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+s_id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(scard.condition)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.operation)
	c:RegisterEffect(e1)
	--Revive
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(scard.sumcon)
	e2:SetTarget(scard.sumtg)
	e2:SetOperation(scard.sumop)
	c:RegisterEffect(e2)
end
function scard.tuner(c)
	return c:IsSetCard(0xa3) or c:IsSetCard(0x43)
end

function scard.cfilter(c,e,tp,eg)
	return c:IsFaceup() and c:GetSummonPlayer()==1-tp and not eg:IsContains(e:GetHandler())
end
function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.ExceptOnDamageCalc()
end
function scard.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa3) and c:HasAttack()
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,scard.costfilter,1,nil)
	end
	e:SetLabel(0)
	local sg=Duel.SelectReleaseGroup(tp,scard.costfilter,1,1,nil)
	if #sg>0 then
		local sc=sg:GetFirst()
		local atk=sc:GetAttack()
		Duel.SetTargetParam(atk)
		Duel.Release(sg,REASON_COST)
		if sc:IsLocation(LOCATION_GRAVE) and sc:GetReason()&(REASON_RELEASE|REASON_COST)==REASON_RELEASE|REASON_COST and not sc:IsReason(REASON_REPLACE) then
			Duel.SetTargetCard(sc)
		end
		local p
		for ip=tp,1-tp,1-2*tp do
			if eg:IsExists(Card.IsControler,1,nil,p) then
				if not p then
					p=ip
				else
					p=PLAYER_ALL
				end
			end
		end
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,eg,#eg,p,LOCATION_MZONE,-math.abs(atk))
	end
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and e:IsActivated() and tc and tc:IsRelateToChain() then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(s_id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
		tc:RegisterFlagEffect(s_id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
	end
	local val=Duel.GetTargetParam()
	if not val then return end
	for ec in aux.Next(eg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetValue(-math.abs(val))
		ec:RegisterEffect(e1)
	end
end

function scard.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(s_id)
end
function scard.spfilter(c,e,tp,fid)
	return c:HasFlagEffectLabel(s_id+100,fid) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function scard.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(scard.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,fid)
	end
	Duel.SetTargetParam(fid)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function scard.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local fid=Duel.GetTargetParam()
	if not fid then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(scard.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,fid)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end