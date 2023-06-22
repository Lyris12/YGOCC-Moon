--Lalaim, Searing Hoopmaster
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	--Bigbang
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE+RACE_PYRO),1,1,aux.TRUE,1)

	Marionightte.Induct(c,200)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg) return not eg:IsContains(e:GetHandler()) end)
	c:RegisterEffect(e2)
end
ref.has_text_race=RACE_MACHINE+RACE_PYRO

function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local val=Duel.GetFlagEffect(tp,id)
	if chkc then return val==2 and chkc:IsAbleToHand() end
	if chk==0 then if val>6 then return false end
		return ((val==0) and Duel.IsPlayerCanDraw(tp,1))
			or (val>0)
	end
	if (val==0 or val==4) then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1) end
	if val>1 then Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800) end
	if val==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
	e:GetHandler():SetHint(CHINT_NUMBER,val)
end
function ref.ssop(e,tp)
	local val=Duel.GetFlagEffect(tp,id)
	if val==0 then Duel.Draw(tp,1,REASON_EFFECT) end
	if val>0 then Duel.Recover(tp,800,REASON_EFFECT) end
	if val==2 then
		--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		--local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
