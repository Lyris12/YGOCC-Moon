--[[
Vacuous Clock Tower
Torre Vacua dell'Orologio
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	--[[If you control "Power Vacuum Zone", or a monster(s) whose original ATK/DEF are 0, except "Vacuous Clock Tower": You can discard 1 other card; Special Summon this card from your hand or GY, and if you do, send 1 "Vacuous" monster from your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		aux.LocationGroupCond(s.cfilter,LOCATION_ONFIELD,0,1),
		aux.DiscardCost(nil,1,1,true),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[During your opponent's turn, if your opponent has activated 5 or more cards or effects while you controlled this card (Quick Effect): You can return this card to your hand; your opponent must
	Tribute 1 monster with 0 original ATK/DEF or 1 monster that was Summoned from the Extra Deck. If they cannot, it becomes the End Phase. You must control "Power Vacuum Zone" and "Power Vacuum
	Blade" to activate and resolve this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		s.rlcon,
		aux.ToHandSelfCost,
		s.rltg,
		s.rlop
	)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAIN_NEGATED)
	e4:SetOperation(s.regop2)
	c:RegisterEffect(e4)
	--[[If this card battles an opponent's monster, neither can be destroyed by that battle, also, at the end of that Damage Step, your opponent loses LP equal to that monster's ATK or DEF (whichever
	is higher, or its ATK if tied).]]
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.indtg)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(id,2)
	e6:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	e6:SetCondition(s.damcon)
	e6:SetTarget(s.damtg)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_POWER_VACUUM_ZONE) or (c:IsLocation(LOCATION_MZONE) and c:IsBaseStats(0,0) and not c:IsCode(id)))
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS) and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,c)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--E2
function s.rlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=tp==0 and id or id+100
	return Duel.IsTurnPlayer(1-tp) and c:HasFlagEffect(fid) and c:GetFlagEffectLabel(fid)>=5
		and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_BLADE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.rlfilter(c)
	return c:IsBaseStats(0,0) or c:IsSummonLocation(LOCATION_EXTRA)
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not Duel.IsEndPhase() or Duel.CheckReleaseGroupEx(1-tp,s.rlfilter,1,REASON_RULE,false,nil)
	end
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),tp,LOCATION_ONFIELD,0,1,nil)
		or not Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_BLADE),tp,LOCATION_ONFIELD,0,1,nil) then
		return
	end
	if Duel.CheckReleaseGroupEx(1-tp,s.rlfilter,1,REASON_RULE,false,nil) then
		local g=Duel.SelectReleaseGroupEx(1-tp,s.rlfilter,1,1,REASON_RULE,false,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Release(g,REASON_RULE,1-tp)
		end
	else
		local p=Duel.GetTurnPlayer()
		Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE|PHASE_END,1)
		Duel.SkipPhase(p,PHASE_STANDBY,RESET_PHASE|PHASE_END,1)
		Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE|PHASE_END,1)
		Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE|PHASE_END,1,1)
		Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE|PHASE_END,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BP)
		e1:SetAbsoluteRange(p,1,0)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--E3+E4
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp then
		local fid=tp==0 and id or id+100
		local flag=c:GetFlagEffectLabel(fid)
		if flag then
			c:SetFlagEffectLabel(fid,flag+1)
		else
			c:RegisterFlagEffect(fid,RESET_EVENT|RESETS_STANDARD,0,1,1)
		end
	end
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp then
		local fid=tp==0 and id or id+100
		local flag=c:GetFlagEffectLabel(fid)
		if flag and flag>0 then
			c:SetFlagEffectLabel(fid,flag-1)
		end
	end
end

--E5
function s.indtg(e,c)
	local h=e:GetHandler()
	local bc=h:GetBattleTarget()
	if not bc or not bc:IsControler(1-e:GetHandlerPlayer()) then return false end
	return c==h or c==bc
end

--E6
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if not bc then return false end
	if bc:IsRelateToBattle() then
		return bc:IsControler(1-tp)
	else
		return bc:IsPreviousControler(1-tp)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=0
	if bc:IsRelateToBattle() then
		dam=bc:GetMaxStat()
	else
		dam=math.max(bc:GetPreviousAttackOnField(),bc:GetPreviousDefenseOnField())
		e:SetLabel(dam)
	end
	e:SetLabelObject(bc)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=0
	local bc=e:GetLabelObject()
	local battle_relation=bc:IsRelateToBattle()
	if battle_relation and bc:IsFaceup() and bc:IsControler(1-tp) then
		dam=bc:GetMaxStat()
	elseif not battle_relation then
		dam=e:GetLabel()
	end
	if dam>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.LoseLP(1-tp,dam)
	end
end