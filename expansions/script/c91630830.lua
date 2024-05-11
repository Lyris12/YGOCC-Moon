--[[
Lich-Lord's Dominion
Dominio del Signore-Lich
Card Author: Walrus
Original Script by: ?
Updated by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and not Duel.PlayerHasFlagEffectLabel(tp,id,1)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and not Duel.PlayerHasFlagEffectLabel(tp,id,2)
	local b3=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) and not Duel.PlayerHasFlagEffectLabel(tp,id,3)
	if chk==0 then return b1 or b2 or b3 end
	local sel=aux.Option(tp,id,1,b1,b2,b3)
	Duel.SetTargetParam(sel)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1,sel+1)
	if sel==0 then
		e:SetCategory(CATEGORY_TOGRAVE|CATEGORIES_SEARCH)
		e:SetOperation(s.tgop(s.filter1))
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif sel==1 then
		e:SetCategory(CATEGORY_TOGRAVE|CATEGORIES_SEARCH)
		e:SetOperation(s.tgop(s.filter2))
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif sel==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	end
end
function s.filter1(c)
	return c:IsSetCard(ARCHE_LICH_LORD) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.filter2(c)
	return c:IsSetCard(ARCHE_LICH_LORD) and c:IsST() and not c:IsCode(id) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tgop(f)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
				if #g>0 then
					local tc=g:GetFirst()
					if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
						Duel.Search(tc,tp)
					else
						Duel.SendtoGrave(tc,REASON_EFFECT)
					end
				end
			end
end

function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummonNegate(e,tc,0,tp,tp,false,false,POS_FACEUP)
	end
end