--[[
Lich-Lord Fulgrum
Signore-Lich Fulgrum
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Lich-Lord Fulgrum".
	c:SetUniqueOnField(1,0,id)
	--During the Main Phase (Quick Effect): You can banish 2 Zombie monsters from either GY, except "Lich-Lord Fulgrum"; Special Summon this card from your hand or GY.
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(aux.MainPhaseCond(),s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
	--During your Standby Phase, if you do not have "Lich-Lord's Phylactery" in your GY: Destroy this card, and if you do, add 1 Zombie monster from your Deck, GY, or banishment to your hand.
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DESTROY|CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(s.sdcon,nil,s.sdtg,s.sdop)
	c:RegisterEffect(e3)
	--[[If you have "Lich-Lord's Phylactery" in your GY, this card gains the following effects.
	● All monsters your opponent controls must attack, if able.
	● If your "Lich-Lord" monster battles, your opponent cannot activate cards or effects until the end of the Damage Step.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_MUST_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(aux.PhylacteryCondition)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(1)
	e5:SetCondition(s.actcon)
	c:RegisterEffect(e5)
end

--E2
function s.scfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and not c:IsCode(id) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.scfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,c)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0)
	end
	local g=aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,false,false,false)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and not aux.PhylacteryCheck(tp)
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	Duel.SetCardOperationInfo(c,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GB)
end
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GB,0,1,1,nil)
		if #g>0 then
			Duel.Search(g,tp)
		end
	end
end

--E4
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_LICH_LORD) and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	if not aux.PhylacteryCondition(e,tp) then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a and s.cfilter(a,tp)) or (d and s.cfilter(d,tp))
end