--[[
Evil Ascension
Ascensione Malvagia
Card Author: Code Coral
Scripted by: Lyris
Rescripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DRAW)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_REPTILE))
	Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c,tp)
	local lv=c:GetLevel()
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE) and c:IsSetCard(ARCHE_EVIL_DRAGON) and c:IsLevelAbove(1) and c:IsDiscardable() and Duel.GetDeckCount(tp)>lv
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,lv,nil)
end
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	local lv=tc:GetLevel()
	Duel.SetTargetParam(lv)
	Duel.SendtoGrave(tc,REASON_DISCARD|REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,lv,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local lv=Duel.GetTargetParam()
	if not lv or lv<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:Select(tp,lv,lv,nil)
	if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)==lv and not Duel.GetOperatedGroup():IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_GRAVE) then
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end