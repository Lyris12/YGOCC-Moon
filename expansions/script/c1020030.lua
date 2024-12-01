--[[
CODED-EYES Renegade Dragon
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,ARCHE_CODED_EYES),aux.FilterBoolFunction(Card.IsFusionSetCard,ARCHE_CODE_JAKE),true)
	--effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT(true)
	e1:SetCondition(aux.FusionSummonedCond)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT(true)
	e2:SetCost(s.damcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_ATTACK,s.counterfilter)
end
function s.counterfilter(c)
	return not c:IsLevelAbove(8)
end

--E1
function s.disfilter(c)
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local opt=Duel.GetChainInfo(e:GetChainLink(),CHAININFO_TARGET_PARAM)
		return opt==2 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.disfilter(chkc)
	end
	e:SetCategory(0)
	local a=Duel.IsAbleToEnterBP() or Duel.IsBattlePhase()
	local b=Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return a or b end
	local opt=aux.Option(tp,id,1,a,b)
	if opt then
		opt=opt+1
	else
		return
	end
	Duel.SetTargetParam(opt)
	if opt==1 then
		e:SetCategory(0)
	elseif opt==2 then
		e:SetCategory(CATEGORY_DISABLE|CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,g:GetFirst():GetAttack())
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=Duel.GetTargetParam()
	if op==1 then
		--atk
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,0)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetCondition(s.atkcon)
		e1:SetOperation(s.atkop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		local tc=Duel.GetFirstTarget()
		if c:IsFaceup() and c:IsRelateToChain() and tc:IsFaceup() and tc:IsRelateToChain() then
			local e1,diff=c:UpdateATK(tc:GetAttack(),RESET_PHASE|PHASE_END,c)
			if not c:IsImmuneToEffect(e1) and diff>0 and tc:IsCanBeDisabledByEffect(e) then
				Duel.Negate(tc,e,0,false,false,TYPE_MONSTER)
			end
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a,d=Duel.GetBattleMonsters(tp)
	return a and d and a:IsFaceup() and a:IsRelateToBattle() and a:IsSetCard(ARCHE_CODE_JAKE)
		and d:IsFaceup() and d:IsRelateToBattle() and d:IsSummonLocation(LOCATION_EXTRA)
end
function s.atkop(e,tp,ep,ev,re,r,rp)
	local a,d=Duel.GetBattleMonsters(tp)
	if a and a:IsRelateToBattle() and d and d:IsFaceup() and d:IsRelateToBattle() and d:IsSummonLocation(LOCATION_EXTRA) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_CARD,tp,id)
		d:UpdateATK(-1000,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
	end
end

--E2
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_ATTACK)==0 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,8))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c)
	return c:IsFaceup() and (c:IsLevelAbove(1) or c:IsRankAbove(1))
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=e:GetHandler() and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	local tc=g:GetFirst()
	local val=math.max(tc:GetLevel(),tc:GetRank())*200
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,PLAYER_ALL,val)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToChain() then return end
	local val=math.max(tc:GetLevel(),tc:GetRank())*200
	if val==0 then return end
	for p in aux.TurnPlayers() do
		Duel.Damage(p,val,REASON_EFFECT,true)
	end
	Duel.RDComplete()
end