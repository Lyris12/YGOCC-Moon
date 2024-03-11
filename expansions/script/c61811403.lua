--[[
Dread Bastille - Rhapsody
Bastiglia dell'Angoscia - Rapsodia
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During the Main or Battle Phase (Quick Effect): You can discard this card, then target 1 "Dread Bastille" monster you control and 1 monster your opponent controls with less DEF than it; negate that opponent's monster's effects.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetRelevantTimings(RELEVANT_BATTLE_TIMINGS)
	e1:SetCondition(aux.MainOrBattlePhaseCond())
	e1:SetCost(aux.DiscardSelfCost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--[[If a Rock monster(s) is Normal or Special Summoned to your field (except during the Damage Step): You can Special Summon this card from your GY, but banish it if it leaves the field.]]
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetLabelObject(GYChk)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[If this card is Special Summoned: You can send 1 "Dread Bastille" Spell/Trap from your Deck to the GY.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:HOPT()
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--E1
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:HasDefense() and Duel.IsExists(true,s.negfilter,tp,0,LOCATION_MZONE,1,c,c:GetDefense()-1)
end
function s.negfilter(c,def)
	return aux.NegateMonsterFilter(c) and c:IsDefenseBelow(def)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	local tc1=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if not tc1 then return end
	local tc2=Duel.Select(HINTMSG_DISABLE,true,tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,tc1,tc1:GetDefense()-1):GetFirst()
	tc2:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetCardOperationInfo(tc2,CATEGORY_DISABLE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards():Filter(Card.HasFlagEffect,nil,id):GetFirst()
	if tc and tc:IsControler(1-tp) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		Duel.Negate(tc,e,0,nil,nil,TYPE_MONSTER)
	end
end

--E2
function s.cfilter(c,tp,se)
	if not (se==nil or c:GetReasonEffect()~=se) then return false end
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return not eg:IsContains(c) and eg:IsExists(s.cfilter,1,nil,tp,se)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.tgfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end