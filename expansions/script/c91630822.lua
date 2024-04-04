--[[
Lich-Lord Zhera
Signore-Lich Zhera
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Lich-Lord Zhera".
	c:SetUniqueOnField(1,0,id)
	--You can discard this card and 1 other Zombie monster; send the top 3 cards of your Deck to the GY, and if you do, draw 1 card.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DECKDES|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your hand or GY: You can banish 1 Zombie monster from your GY, except "Lich-Lord Zhera"; Special Summon this card in Defense Position.
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
	--While you have "Lich Lord's Phylactery" in your GY, you choose the attack targets for your opponent's attacks.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(aux.PhylacteryCondition)
	c:RegisterEffect(e4)
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
	if chk==0 then return Duel.GetDeckCount(tp)>3 and Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.DiscardDeck(p,3,REASON_EFFECT)==3 then
		local g=Duel.GetOperatedGroup()
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if ct==3 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
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