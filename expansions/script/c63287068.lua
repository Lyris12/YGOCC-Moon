--Numero O. 119: Re Rana Squath
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x12),2,3)
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.adval)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e1x)
	--cannot direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.imtg)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(aux.MainPhaseCond(0))
	e4:SetCost(aux.DetachSelfCost())
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.adval(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(aux.Faceup(Card.IsSetCard),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,0x12)*700
end

function s.imtg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x12)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.spfil(c,e,tp)
	return c:IsMonster() and (c:IsSetCard(0x12) or c:IsCode(10456559)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackAbove(300) and c:IsDefenseAbove(300) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,-300)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,c,1,0,0,-300)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1,diff1=c:UpdateATK(-300,RESET_PHASE+PHASE_END)
		local e2,diff2=c:UpdateDEF(-300,RESET_PHASE+PHASE_END)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if not c:IsImmuneToEffect(e1) and diff1==-300 and not c:IsImmuneToEffect(e2) and diff2==-300 and ft>0 then
			local ct = (ft<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and 1 or 2
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfil,tp,LOCATION_DECK,0,1,ct,nil,e,tp)
			if #g~=0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end