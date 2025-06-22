--[[
Remnant Parasite
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--If you control a face-up DARK monster that has a Level/Rank: You can target 1 of those monsters; Special Summon this card from your hand, and if you do, this card's Level becomes equal to the Level/Rank of that target.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)    
	--[[If this card is detached from an Xyz Monster to activate a card or effect: You can add 1 "Rank-Up-Magic", "Rank-Down-Magic", "Number", or "Remnant" Spell/Trap from your Deck, GY, or banishment to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetSearchFunctions(s.thfilter,LOCATION_DECK|LOCATION_GB)
	c:RegisterEffect(e2)
end	
--E1
function s.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and (c:HasLevel() or c:HasRank())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(true,s.spfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToChain() and s.spfilter(tc) then
		local rating=tc:GetRatingAuto(RATING_LEVEL|RATING_RANK)
		if rating>0 then
			c:ChangeLevel(rating,true,c)
		end
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re then return false end
	local ef={c:IsHasEffect(EFFECT_REMEMBER_XYZ_HOLDER)}
	if #ef==0 then return false end
	local eff=ef[1]
	local xyz=eff:GetLabelObject()
	if not xyz then return false end
	return c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_OVERLAY) and re:IsActivated() and xyz:IsType(TYPE_XYZ)
end
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsST() and c:IsSetCard(ARCHE_RUM,ARCHE_RDM,ARCHE_NUMBER,ARCHE_REMNANT)
end