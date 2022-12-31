--Lich-Lord's Black Book
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--summon proc
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9163835,10))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.otcon)
	e2:SetTarget(cid.ottg)
	e2:SetOperation(cid.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
	--summon proc
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9163835,10))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(cid.otcon1)
	e4:SetTarget(cid.ottg1)
	e4:SetOperation(cid.otop1)
	e4:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e5)
	--summon proc
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(9163835,10))
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_SUMMON_PROC)
	e6:SetTargetRange(LOCATION_HAND,0)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(cid.otcon2)
	e6:SetTarget(cid.ottg2)
	e6:SetOperation(cid.otop2)
	e6:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e7)
	--maintain
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(cid.mtcon)
	e8:SetOperation(cid.mtop)
	c:RegisterEffect(e8)
	--If this card is in the GY, except during the turn it was sent to the GY: You can target 1 of your banished Zombie monsters, or 1 of your banished "Lich-Lord" Spell/Traps; shuffle this card into your Deck, and if you do, add that target to your hand. You can only use this effect of "Lich-Lord's Black Book" once per turn.
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_GRAVE)
	e9:SetCountLimit(1,id)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e9:SetCondition(aux.exccon)
	e9:SetTarget(cid.tg)
	e9:SetOperation(cid.op)
	c:RegisterEffect(e9)
end
function cid.rmfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function cid.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cid.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=1 and ma>=1 and c:IsSetCard(0x2e7)
end
function cid.otop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function cid.otcon1(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil)
end
function cid.ottg1(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2 and c:IsSetCard(0x2e7)
end
function cid.otop1(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function cid.otcon2(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,nil)
end
function cid.ottg2(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=3 and ma>=3 and c:IsSetCard(0x2e7)
end
function cid.otop2(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function cid.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,1000) and Duel.SelectYesNo(tp,aux.Stringid(9163835,6)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.PayLPCost(tp,1000)
	else
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoDeck(e:GetHandler(),nil,1,REASON_COST)
	end
end
function cid.filter(c)
	if c:IsFacedown() or not c:IsAbleToHand() then return false end
	if c:IsType(TYPE_MONSTER) then return c:IsRace(RACE_ZOMBIE)
	else return c:IsSetCard(0x2e7) end
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and cid.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(cid.filter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.SelectTarget(tp,cid.filter,tp,LOCATION_REMOVED,0,1,1,nil),1,0,0)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,2,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_DECK) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
