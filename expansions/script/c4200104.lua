--created & coded by Swag
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetSPSummonOnce(id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.sslimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(cid.settg)
	e2:SetOperation(cid.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function cid.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x412)
end
function cid.setfilter(c)
	return c:IsSetCard(0x412) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function cid.sparkfilter(c)
	return c:IsCode(id-4)
end
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.setfilter,tp,LOCATION_DECK,0,1,nil) end
	if Duel.IsExistingMatchingCard(cid.sparkfilter,tp,LOCATION_GRAVE,0,1,nil) then
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_MONSTER)
		if #g>0 then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		end
	end
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	local ifclause=false
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SSet(tp,g)>0 and Duel.IsExistingMatchingCard(cid.sparkfilter,tp,LOCATION_GRAVE,0,1,nil) then
			ifclause=true
		end
		if ifclause and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_MONSTER) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_MONSTER)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end