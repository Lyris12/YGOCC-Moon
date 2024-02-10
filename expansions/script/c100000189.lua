--[[
Mythical Deity of the Fairy Circle
Mitica Divinità del Circolo Fatato
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,aux.NonTuner(nil),nil,nil,aux.Tuner(aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND)),1,99)
	c:EnableReviveLimit()
	--[[If this card is Synchro Summoned: You can target 1 Plant or Insect monster in your GY; Special Summon it.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(aux.SynchroSummonedCond)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If a monster(s) on the field is destroyed: This card gains 1000 ATK, also this card can make up to 3 attacks during each Battle Phase this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--If this card is destroyed: You can activate this effect; negate the next card or effect your opponent activates this turn, and if you do, destroy it.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:HOPT()
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
--E1
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_PLANT|RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(sg,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.ctcfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.ctcfilter,1,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		c:UpdateATK(1000,true,c)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_EXTRA_ATTACK_3)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end

--E3
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:Desc(3)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:OPT()
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_PLAYER)
	return p==1-tp and re:IsActivated() and not Duel.PlayerHasFlagEffect(tp,id)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end