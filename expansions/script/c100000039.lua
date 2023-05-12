--Rêverie du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[When this card is activated: You can add 1 "Vaisseau" monster from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If a "Vaisseau" Pendulum Monster(s) leaves the field: You can add 1 face-up "Vaisseau" Pendulum Monster from your Extra Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(ARCHE_VAISSEAU) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and not Duel.PlayerHasFlagEffect(tp,id) and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end

function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(ARCHE_VAISSEAU) and c:IsPreviousTypeOnField(TYPE_PENDULUM)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.thfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end