--Hawk
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	--synchro summon
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,s_id+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(scard.con)
	e1:SetTarget(scard.tg)
	e1:SetOperation(scard.op)
	c:RegisterEffect(e1)
	aux.AddSynchroProcedure(c,Card.IsMantra,aux.NonTuner(nil),1)
end
function scard.syn(c)
	return aux.NonTuner(Card.IsMantra)
end
function scard.con(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function scard.filter(c)
	return c:IsMantra() and c:IsType(TYPE_MONSTER) and not c:IsCode(s_id)
end
function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
end
function scard.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(scard.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,nil)
	local g=0
	if rg:GetCount()>0 then 
        local tg=Group.CreateGroup()
        local i=3
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local tc=rg:Select(tp,1,1,nil):GetFirst()
        rg:Remove(Card.IsCode,nil,tc:GetCode())
        tg:AddCard(tc)
        i=i-1
		g=g+1
		if rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(s_id,0)) then
			repeat
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tc=rg:Select(tp,1,1,nil):GetFirst()
			rg:Remove(Card.IsCode,nil,tc:GetCode())
			tg:AddCard(tc)
			i=i-1
			g=g+1
			until i<1 or rg:GetCount()==0 or not Duel.SelectYesNo(tp,aux.Stringid(s_id,0))
		end
        Duel.SendtoGrave(tg,REASON_EFFECT)
    end
	if g>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(g*600)
		e1:SetReset(RESET_EVENT+0x1ff0000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
