--Break Through! Golden Skies!
--Scripted by Yuno
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
    --Activate and send a "Golden Skies Treasure" to GY to target a face-up card and destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end

--Activate and send a "Golden Skies Treasure" to GY to target a face-up card and destroy it

function cid.confilter(c)
    return c:IsSetCard(0x528) and c:IsFaceup()
end
function cid.condition(e, tp, eg, ep, ev, re, r, rp)
    if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(cid.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function cid.tgfilter(c)
	return c:IsCode(11111040) and c:IsAbleToGrave()
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, e:GetHandler())
		and Duel.IsExistingMatchingCard(cid.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, e:GetHandler())
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, cid.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if g:GetCount()>0 then
		local sg=g:GetFirst()
		if Duel.SendtoGrave(g, REASON_EFFECT)~=0 and sg:IsLocation(LOCATION_GRAVE) then
			local tc=Duel.GetFirstTarget()
			if tc:IsFaceup() and tc:IsRelateToEffect(e) then
				Duel.Destroy(tc, REASON_EFFECT)
			end
		end
	end
end