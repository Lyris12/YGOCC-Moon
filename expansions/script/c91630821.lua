--[[
Lich-Lord Hraxx'n
Signore-Lich Hraxx'n
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Lich-Lord Hraxx'n".
	c:SetUniqueOnField(1,0,id)
	--You can discard this card and 1 other Zombie monster; add 1 "Lich-Lord" Spell/Trap from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your hand or GY: You can banish 1 Zombie monster from your GY, except "Lich-Lord Hraxx'n"; Special Summon this card in Defense Position.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
	--During your Standby Phase, if you do not have "Lich-Lord's Phylactery" in your GY: Destroy this card.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(s.sdcon,nil,s.sdtg,s.sdop)
	c:RegisterEffect(e3)
	--While you have "Lich-Lord's Phylactery" in your GY, all Zombie monsters you control can be treated as any Level between 1 and 8 for the Xyz Summon of a Zombie Xyz Monster.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_XYZ_LEVEL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(aux.PhylacteryCondition)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e4:SetValue(s.xyzlv)
	e4:SetLabel(1)
	c:RegisterEffect(e4)
	for i=2,8 do
		local clone=e4:Clone()
		clone:SetLabel(i)
		c:RegisterEffect(clone)
	end
end

--E1
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_DISCARD|REASON_COST)
end
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_LICH_LORD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

--E2
function s.scfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and not c:IsCode(id) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_GRAVE,0,1,c,tp)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.scfilter,tp,LOCATION_GRAVE,0,1,1,c,tp)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
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
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Destroy(c,REASON_EFFECT)
	end
end

--E4
function s.xyzlv(e,c,rc)
	if rc:IsRace(RACE_ZOMBIE) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end