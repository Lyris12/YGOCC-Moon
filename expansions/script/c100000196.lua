--[[
Kakuren, The Seeking Prey
Kakuren, La Preda Cercatrice
Card Author: Kinny
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If your opponent activates a card effect in their hand (except during the Damage Step): You can Special Summon this card from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[When your opponent activates the effect of a monster with 2000 or more ATK, while this card is banished (Quick Effect):
	You can target 1 EARTH Beast you control; banish it (until the End Phase), then Special Summon this card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_REMOVED)
	e2:HOPT()
	e2:SetFunctions(s.spcon2,nil,s.sptg2,s.spop2)
	c:RegisterEffect(e2)
end
--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=1-tp then return false end
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return p==1-tp and loc==LOCATION_HAND
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	if ep~=1-tp or not re:IsActiveType(TYPE_MONSTER) then return false end
	local atk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_ATTACK)
	return atk>=2000
end
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:IsAbleToRemoveTemp() and Duel.GetMZoneCount(tp,c)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(true,s.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.BanishUntil(tc,e,tp,nil,nil,id)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end