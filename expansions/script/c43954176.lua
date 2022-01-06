--The All-World Felgrandria
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(cid.val)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2x)
	--effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(cid.target)
	e3:SetOperation(cid.operation)
	c:RegisterEffect(e3)
end
cid.FELGRAND={1639384,3954901,6075801,33460840,60681103}
--ATK/DEF
function cid.valfilter(c)
	return c:IsSetCard(0xfe9) or c:IsCode(table.unpack(cid.FELGRAND))
end
---------
function cid.val(e,c)
	return Duel.GetMatchingGroupCount(cid.valfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
end
--EFFECT
function cid.filter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and cid.valfilter(c)
		and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_GRAVE,0,1,c,tp)
end
function cid.eqfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and (c:IsLevel(7,8) or c:IsRank(7,8) or c:IsLink(3,4))
end
function cid.cfilter1(c,tp)
	return cid.valfilter(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() and c:IsLevelBelow(4)
		and Duel.IsExistingMatchingCard(cid.cfilter2,tp,LOCATION_GRAVE,0,1,c,tp,c)
end
function cid.cfilter2(c,tp,tc)
	if c:IsCode(tc:GetCode()) then return false end
	return cid.valfilter(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() and c:IsLevelBelow(4)
end
function cid.cfilter3(c)
	return c:IsFaceup() and c:IsReleasable()
end
function cid.scfilter(c)
	return c:IsCode(6853254,38120068) and c:IsAbleToHand()
end
function cid.scfilter2(c)
	return cid.valfilter(c) and not c:IsCode(id) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
--------
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=(Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
	local b2=(Duel.IsExistingMatchingCard(cid.cfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.IsExistingMatchingCard(cid.scfilter,tp,LOCATION_DECK,0,1,nil))
	local b3=(Duel.IsExistingMatchingCard(cid.cfilter3,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) and Duel.IsExistingMatchingCard(cid.scfilter2,tp,LOCATION_DECK,0,1,nil))
	if chkc then return (e:GetLabel()==0 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cid.filter(chkc,tp)) end
	if chk==0 then return b1 or b2 or b3 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,1)
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,2)
		opval[off]=1
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,3)
		opval[off]=2
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,sel+1))
	if sel==0 then
		e:SetCategory(CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	elseif sel==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g1=Duel.SelectMatchingCard(tp,cid.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,cid.cfilter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),tp,g1:GetFirst())
		g1:Merge(g2)
		Duel.SendtoDeck(g1,nil,2,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g1=Duel.SelectMatchingCard(tp,cid.cfilter3,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
		Duel.Release(g1,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if sel==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local tc=Duel.GetFirstTarget()
		if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if ec then
			Duel.Equip(tp,ec,tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(cid.eqlimit)
			e1:SetLabelObject(tc)
			ec:RegisterEffect(e1)
		end
	elseif sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,cid.scfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(44335251,2))
		local g=Duel.SelectMatchingCard(tp,cid.scfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	end
end
----
function cid.eqlimit(e,c)
	return c==e:GetLabelObject()
end