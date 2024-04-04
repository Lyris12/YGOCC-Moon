--[[
Lich-Lord's Phylactery
Filatterio del Signore-Lich
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Tribute 1 Zombie monster; Special Summon 1 "Lich-Lord" monster from your Deck. If you control a Zombie Xyz Monster, you can Tribute 1 monster your opponent controls, instead.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(nil,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e1)
	if not s.effect_table then
		s.effect_table={}
	end
	s.effect_table[e1]=true
	--[[If you control both a "Lich-Lord" monster and "Zombie World" while this card is in your GY, all Zombie monsters you control gain 300 ATK/DEF.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.statcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
	--[[Once per turn, during your Standby Phase, if this card is in your GY, Tribute 1 Zombie monster you control or banish this card.
	You do not have to activate this effect if you control an Xyz Summoned DARK "Number" Xyz Monster.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:OPT()
	e3:SetCondition(aux.TurnPlayerCond(0))
	e3:SetOperation(s.maintop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s[0]=false
		s[1]=false
		s.global_check=true
		local ge=Effect.CreateEffect(c)
		ge:SetDescription(aux.Stringid(id,2))
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
		ge:SetAbsoluteRange(0,0,LOCATION_MZONE)
		ge:SetCondition(s.relcon(0))
		ge:SetValue(s.relval)
		Duel.RegisterEffect(ge,0)
		local ge2=ge:Clone()
		ge2:SetAbsoluteRange(1,0,LOCATION_MZONE)
		ge2:SetCondition(s.relcon(1))
		Duel.RegisterEffect(ge2,1)
	end
end
function s.relcon(p)
	return	function(e)
				return s[p]==true
			end
end
function s.relval(e,re,r,rp)
	return r&REASON_COST==REASON_COST and re and s.effect_table[re]==true
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_ZOMBIE)
end
function s.costfilter(c,tp)
	return (c:IsRace(RACE_ZOMBIE) or c:IsControler(1-tp)) and Duel.GetMZoneCount(tp,c,tp)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local temp
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		temp=s[tp]
		s[tp]=true
	end
	if chk==0 then
		local res=Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp)
		if type(temp)~="nil" then
			s[tp]=temp
		end
		return res
	end
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
	if type(temp)~="nil" then
		s[tp]=temp
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_LICH_LORD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.filter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_LICH_LORD) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ZOMBIE_WORLD),tp,LOCATION_ONFIELD,0,1,c)
end
function s.statcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp)
end

--E3
function s.savefilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(ARCHE_NUMBER) and c:IsXyzSummoned()
end
function s.maintfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
function s.maintop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	if Duel.IsExistingMatchingCard(s.savefilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	if Duel.CheckReleaseGroupEx(tp,s.maintfilter,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local g=Duel.SelectReleaseGroupEx(tp,s.maintfilter,1,1,REASON_MAINTENANCE,false,c)
		Duel.Release(g,REASON_MAINTENANCE)
	else
		Duel.Remove(c,POS_FACEUP,REASON_COST)
	end
end