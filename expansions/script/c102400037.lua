--created & coded by Lyris, art from "Galaxy-Eyes Photon Dragon"
--スターリ・アイズ・スぺーシュル・ドラゴン(アナザー宙)
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,nil,7,aux.TRUE,2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_REMOVE)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and aux.nzatk(c) and c:IsAbleToRemove()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,TYPE_MONSTER) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,tc:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)>0 then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
