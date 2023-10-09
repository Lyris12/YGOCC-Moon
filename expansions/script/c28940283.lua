--Sunhewer of Economics, Advant
local ref,id=GetID()
Duel.LoadScript("Sunhew.lua")
function ref.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,4)
	c:DriveEffect(0,0,CATEGORIES_SEARCH,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_DELAY,EVENT_ENGAGE,
		nil,
		nil,
		ref.thtg,
		ref.thop
	)
	local d1=c:DriveEffect(0,0,0,EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS,nil,EVENT_CHAIN_SOLVING,nil,nil,nil,
		ref.regop)
	d1:SetLabel(0)
	local d2=c:DriveEffect(0,0,0,EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS,nil,EVENT_CHAIN_SOLVED,nil,nil,nil,
		ref.enop)
	d2:SetLabelObject(d1)
	----Monster Effects
	--Destroy
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(function(e) local c=e:GetHandler()
		return c:IsSummonType(SUMMON_TYPE_DRIVE) or c:IsSummonType(SUMMON_TYPE_NORMAL) end)
	e3:SetTarget(ref.destg)
	e3:SetOperation(ref.desop)
	c:RegisterEffect(e3)
	--To Grave
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:HOPT()
	e4:SetCost(ref.grcost)
	e4:SetTarget(ref.grtg)
	e4:SetOperation(ref.grop)
	c:RegisterEffect(e4)
end

function ref.regfilter(c)
	if c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_ONFIELD) and c:IsFacedown()) then return true end
	local typ=c:GetType()
	return not (c:IsType(TYPE_QUICKPLAY+TYPE_COUNTER)
		or typ==TYPE_SPELL or typ==TYPE_TRAP or typ==TYPE_SPELL+TYPE_RITUAL)
end
function ref.regop(e,tp,eg,rp,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	e:SetLabel(ct)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
function ref.enop(e,tp) local c=e:GetHandler()
	if not (c:GetFlagEffect(id)>0) then return end
	local oct=e:GetLabelObject():GetLabel()
	local ct=Duel.GetMatchingGroupCount(ref.regfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	local oen=c:GetEnergy()
	--Debug.Message("Old Count: "..oct..", New Count: "..ct)
	--Debug.Message("Energy: "..oen)
	local en=math.min(ct-oct,6-oen)
	if en>0 then
		Duel.Hint(HINT_CARD,tp,id)
		c:UpdateEnergy(en,tp,REASON_EFFECT,true)
	end
	e:GetLabelObject():SetLabel(0)
end

--Search
function ref.thfilter(c) return Sunhew.Is(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id) end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,g) end
end

--Destroy
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function ref.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--To Grave
function ref.grcfilter(c) return Sunhew.Is(c) and c:IsAbleToDeckOrExtraAsCost() end
function ref.grcost(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost()
		and Duel.IsExistingMatchingCard(ref.grcfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,ref.grcfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function ref.grfilter(c) return Sunhew.Is(c) and c:IsAbleToGrave() end
function ref.grtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function ref.grop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
