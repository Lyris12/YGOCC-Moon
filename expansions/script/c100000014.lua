--Kitsune Support Spirit
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--If you control no monsters, you can Special Summon this card (from your hand).
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(s.spsumcon)
	c:RegisterEffect(e1)
	--[[During your Main Phase: You can send 1 Level 3 Beast monster from your Deck to the GY with a different Attribute
	than the monsters you control or in your GY, and if you do, this card becomes a Tuner until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--During your opponent's turn, if you control another Beast monster (Quick Effect): You can Tribute this card, then target 1 monster your opponent controls; return it to the hand.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(0,RELEVANT_TIMINGS)
	e3:SetCondition(s.thcon)
	e3:SetCost(aux.TributeSelfCost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.spsumcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

function s.attfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:GetAttribute()~=0
end
function s.tgfilter(c,tp,g)
	return c:IsMonster() and c:IsLevel(3) and c:IsRace(RACE_BEAST) and c:IsAbleToGrave()
		and not g:IsExists(Card.IsAttribute,1,nil,c:GetAttribute())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local attg=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp,attg)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and aux.PLChk(g,nil,LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsFaceup() then 
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end

function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end