--[[
Crystarion Cobalt Verdict
Verdetto Cobalto Cristarione
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate 1 of these effects, depending on whose turn it is.
	● Your turn: Send 1 "Crystarion Ascendant - Pillar of Cobalt" from your Deck to the GY, and if you do, you can add 1 "Crystarion" monster from your GY to your hand. 
	● Opponent's turn: Reduce the Energy of your Engaged "Crystarion" Drive Monster by 3, and if you do, destroy 1 face-up card on the field.]]
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
function s.tgfilter(c)
	return c:IsCode(CARD_CRYSTARION_ASCENDANT_PILLAR_OF_COBALT) and c:IsAbleToGrave()
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_CRYSTARION) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	local b1=Duel.GetTurnPlayer()==tp and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetTurnPlayer()==1-tp and en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-3,tp,REASON_EFFECT,e)
		and Duel.IsExists(false,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_TOGRAVE|CATEGORY_TOHAND|CATEGORY_GRAVE_ACTION)
		e:SetCustomCategory(0)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	elseif opt==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetCustomCategory(CATEGORY_UPDATE_ENERGY)
		Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_ENERGY,en,1,INFOFLAG_DECREASE,3)
		local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_ONFIELD)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:GetFirst():IsLocation(LOCATION_GRAVE) then
			local mg=Duel.Group(aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,nil)
			if #mg>0 and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=mg:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.Search(sg,tp)
				end
			end
		end
	
	elseif opt==1 then
		local c=e:GetHandler()
		local en=Duel.GetEngagedCard(tp)
		if en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-3,tp,REASON_EFFECT,e) then
			local mod,diff=en:UpdateEnergy(-3,tp,REASON_EFFECT,true,c,e)
			if diff~=0 and not en:IsImmuneToEffect(mod) then
				local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
				if #sg>0 then
					Duel.HintMessage(tp,HINTMSG_DESTROY)
					local spg=sg:Select(tp,1,1,nil)
					if #spg>0 then
						Duel.HintSelection(spg)
						Duel.Destroy(spg,REASON_EFFECT)
					end
				end
			end
		end
	end
end