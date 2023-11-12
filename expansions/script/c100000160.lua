--[[
Crystarion Diamond Contract
Contratto di Diamante Cristarione
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate 1 of these effects, depending on whose turn it is.
	● Your turn: Add 1 "Crystarion" Drive Monster from your Deck to your hand.
	● Opponent's turn: Add 1 "Crystarion" Drive Monster from your GY to your hand, and if you do, Engage it.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.thfilter1(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_CRYSTARION) and c:IsAbleToHand()
end
function s.thfilter2(c,tp,e)
	return s.thfilter1(c) and c:IsCanEngage(tp,false,e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	local b1=Duel.GetTurnPlayer()==tp and Duel.IsExists(false,s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetTurnPlayer()==1-tp and Duel.IsExists(false,s.thfilter2,tp,LOCATION_GRAVE,0,1,nil,tp,e)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORIES_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif opt==1 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if #tg>0 then
			Duel.Search(tg,tp)
		end
	
	elseif opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil,tp,e)
		if #tg>0 then
			Duel.SearchAndEngage(tg:GetFirst(),e,tp,true)
		end
	end
end