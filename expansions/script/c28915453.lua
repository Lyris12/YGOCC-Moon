--Phantomb Guardian, 
local ref,id=GetID()
function ref.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigPandemoniumType(c)

	
	--local regfield,typ,actcon,actcost,hoptnum,acthopt,forced=nil,TYPE_PANDEMONIUM+TYPE_EFFECT,nil,nil,1,nil,false
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id+2000)
	e1:SetCondition(aux.PandActCheck)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	--c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1,TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM,nil,nil,1,nil,false)
	--Gain Effects
	---Spin
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(ref.rmcon)
	e2:SetTarget(ref.rmtg)
	e2:SetOperation(ref.rmop)
	c:RegisterEffect(e2)
	---SEND
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(ref.matctcon(1))
	e3:SetTarget(ref.tgtg)
	e3:SetOperation(ref.tgop)
	c:RegisterEffect(e3)
end

--Activate
function ref.descfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x732)
end
function ref.desfilter(c)
	return c:IsDestructable() and bit.band(c:GetSummonLocation(),LOCATION_EXTRA)==LOCATION_EXTRA
end
function ref.desfilter2(c,exg)
	return Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
		and c:IsDestructable()
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsExistingMatchingCard(ref.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and ref.filter(chkc) end
	if chk==0 then return b1 or b2 end
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5))
	elseif b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,4))+1
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,5))+2
	end
	local g=Group.CreateGroup()
	if opt==0 or opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g:AddCard(Duel.SelectMatchingCard(tp,ref.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst())
	end
	if opt==0 or opt==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g:AddCard(Duel.SelectMatchingCard(tp,ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g:GetFirst()):GetFirst())
	end
	Duel.SetTargetCard(g)
	--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	--local g=Duel.SelectTarget(tp,ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if not (#tg>0 and c:IsRelateToEffect(e)) then return false end
	if Duel.Destroy(tg,REASON_EFFECT)~=0 then
		Duel.Destroy(c,REASON_EFFECT)
	end
end

--Shared Conditions
function ref.matctcon(ct)
	return function(e)
		local c=e:GetHandler()
		local mg=c:GetMaterial()
		return c:GetSummonType()==SUMMON_TYPE_RITUAL and #mg>=ct
	end
end
function ref.loccon(loc)
	return function(e)
		return bit.band(e:GetHandler():GetSummonLocation()&loc)==loc
	end
end
--SEND
function ref.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
	if e:GetHandler():GetMaterialCount()>=2 then Duel.SetChainLimit(ref.chlimit) end
end
function ref.chlimit(e,ep,tp)
	return tp==ep
end
function ref.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--Delet
function ref.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonLocation(),LOCATION_DECK)~=LOCATION_DECK
		and Duel.GetTurnPlayer()==tp
end
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function ref.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then Duel.SendtoDeck(g,nil,2,REASON_RULE) end
		--Duel.Remove(g,POS_FACEDOWN,REASON_RULE)
	--end
end
