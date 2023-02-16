--Mantra Spider
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,s_id)
	e1:SetCondition(scard.descon)
	e1:SetTarget(scard.destg)
	e1:SetOperation(scard.desop)
	c:RegisterEffect(e1)
end
function scard.descon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetBattleMonster(tp)
	if not (ac and ac:IsFaceup() and ac:IsMantra()) then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
function scard.filter(c)
	return c:IsMonster() and c:IsMantra() and c:IsAbleToGrave()
end
function scard.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetCardOperationInfo(bc,CATEGORY_DESTROY)
end
function scard.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,scard.filter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and aux.PLChk(g,nil,LOCATION_GRAVE) then
		local bc=e:GetLabelObject()
		if bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() then
			Duel.Destroy(bc,REASON_EFFECT)
		end
	end
end
