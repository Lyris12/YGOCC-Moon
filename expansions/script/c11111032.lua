--The Winged Castle in the Golden Skies
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
    --Activate and search a "Golden Skies" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
    --Send "Golden Skies Treasure" to GY if a "Golden Skies" monster is Normal Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	--Increase the ATK of all "Golden Skies" monsters if a "Golden Skies" monster is Special Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(cid.atkcon)
	e3:SetOperation(cid.atkop)
	c:RegisterEffect(e3)
end

--Activate and search a "Golden Skies" monster

function cid.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x528) and c:IsAbleToHand()
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(cid.thfilter, tp, LOCATION_DECK, 0, nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local sg=g:Select(tp, 1, 1, nil)
		Duel.SendtoHand(sg, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, sg)
	end
end

--Send "Golden Skies Treasure" to GY if a "Golden Skies" monster is Normal Summoned

function cid.filter(c)
	return c:IsCode(11111040) and c:IsAbleToGrave()
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsSetCard(0x528) and Duel.IsExistingMatchingCard(cid.filter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function cid.operation(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, cid.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
	end
end

--Increase the ATK of all "Golden Skies" monsters if a "Golden Skies" monster is Special Summoned

function cid.cfilter(c, tp)
	return c:IsFaceup() and c:IsSetCard(0x528)
end
function cid.atkcon(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(cid.cfilter, 1, nil, tp)
end
function cid.atkop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsSetCard, tp, LOCATION_MZONE, 0, nil, 0x528)
	local tc=g:GetFirst()
	while tc do
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(100)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end