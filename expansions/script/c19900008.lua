--Geneseed Cherry Manticore
local cid,id=GetID()
function cid.initial_effect(c)
c:EnableReviveLimit()
	   aux.AddOrigEvoluteType(c)
	 aux.AddEvoluteProc(c,nil,7,aux.AND(cid.filter1,cid.filter2),2,99)  
	--discard deck & draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(cid.drcost)
	e1:SetOperation(cid.drop)
	c:RegisterEffect(e1)
	--attack all
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function cid.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
end

function cid.drop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(-500)
		e1:SetRange(LOCATION_MZONE)
		 e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		--indes
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	tc:RegisterEffect(e2)
	end
end
function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or c:IsRace(RACE_WYRM)
end
