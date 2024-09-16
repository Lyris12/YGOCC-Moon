--Eptamagi's Memory, Firmago
--Memoria degli Eptamagi, Firmago
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumMod(EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE)
	aux.EnablePendulumAttribute(c)
	--[[You can perform a Pendulum Summon even if there is not a Pendulum Monster Card in your other Pendulum Zone, treating the missing Pendulum Scale as 0.
	If you do this, you can only Pendulum Summon "Eptamagi" monsters and/or DARK Spellcaster monsters.]]
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE)
	e0:SetTarget(s.pendtg)
	e0:SetValue(0)
	c:RegisterEffect(e0)
	--[[If there is an "Eptamagi" Monster Card in your other Pendulum Zone, except "Eptamagi's Memory, Firmago":
	You can Special Summon 1 "Eptamagi" Monster Card from your Pendulum Zone, and if you do, you can add 1 Level 7 DARK Spellcaster monster from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
end


function s.pendtg(e,c)
	return c:IsSetCard(ARCHE_EPTAMAGI) or c:IsAttributeRace(ATTRIBUTE_DARK,RACE_SPELLCASTER)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_EPTAMAGI) and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function s.penfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_EPTAMAGI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsLevel(7) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_SPELLCASTER) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
		local sg=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end