--created by Walrus, coded by XGlitchy30
--Voidictator Servant - Shield of Corvus
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(s.condition)
	e1:SetCost(aux.BanishCost(s.cfilter,LOCATION_GRAVE))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.cfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase() then return end
	local at=Duel.GetAttacker()
	return at:GetControler()~=tp and Duel.GetAttackTarget()==nil
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsBattlePhase() then
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if not (rc and rc:IsOwner(tp)) then return false end
	local ch=Duel.GetCurrentChain()
	local cid,code1,code2=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	if re:IsActivated() then
		if rc:IsRelateToChain(ch) then
			return rc:IsSetCard(setc) and not rc:IsCode(id)
		else
			return s.TriggeringSetcode[cid] and code1~=id and (not code2 or code2~=id)
		end
	else
		return rc:IsSetCard(setc) and not rc:IsCode(id)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeckAsCost() and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,c,e,tp)
	end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsCostChecked() then return true end
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
