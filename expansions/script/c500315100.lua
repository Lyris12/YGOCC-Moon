--Hinata, Queen of Gust Vine
function c500315100.initial_effect(c)
		   c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,c500315100.mfilterx,c500315100.ffilter,true)

	 --discard deck & draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,500315101)
	  e1:SetTarget(c500315100.distg2)
	e1:SetOperation(c500315100.desop2)
	c:RegisterEffect(e1)
	
		local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	
		--Activate
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(500315100,0))
	e7:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCountLimit(1,500315100)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e7:SetCondition(c500315100.descon)
	e7:SetTarget(c500315100.destg)
	e7:SetOperation(c500315100.desop)
	e7:SetLabelObject(e1)
	c:RegisterEffect(e7)
end
function c500315100.mfilterx(c)
	return c:IsSetCard(0x885a) and c:IsType(TYPE_MONSTER) and not c:IsCode(500315100) 
end
function c500315100.ffilter(c)
	return  c:IsRace(RACE_PLANT)
end

function c500315100.remtg(e,c)
	return c==e:GetHandler()
end
function c500315100.descon(e,tp,eg,ep,ev,re,r,rp)
	return  ( e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION or e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION+0x786)and e:GetHandler():GetMaterial():IsExists(Card.IsSetCard,2,nil,0x885a)
end
function c500315100.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsAbleToRemove() then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
		if tc:IsFaceup() and tc:GetSummonLocation()==LOCATION_EXTRA and not tc:IsType(TYPE_FUSION)  then
			Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
		end
	end
end
function c500315100.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_MONSTER) and tc:GetSummonLocation()==LOCATION_EXTRA  and not tc:IsType(TYPE_FUSION) then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end

function c500315100.cfilter(c)
	return c:IsSetCard(0x885a) and c:IsLocation(LOCATION_GRAVE)
end
function c500315100.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function c500315100.desop2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p,d,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c500315100.cfilter,nil)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct~=0 and Duel.SelectYesNo(tp,aux.Stringid(500315100,0)) then
		Duel.BreakEffect()
	   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		  Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)
	end
end