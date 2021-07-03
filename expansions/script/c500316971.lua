--Buttercup of Fiber VINE 
function c500316971.initial_effect(c)
	  aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,7,c500316971.filter1,1,1)
		--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(500316971,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	--e2:SetCountLimit(1,500316971)
	e2:SetCondition(c500316971.thcon)
	e2:SetTarget(c500316971.thtg)
	e2:SetOperation(c500316971.thop)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--spsum limit
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD)
	e3x:SetRange(LOCATION_MZONE)
	e3x:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3x:SetTargetRange(1,0)
	e3x:SetCondition(c500316971.sumlimcon)
	e3x:SetTarget(c500316971.sumlimit)
	c:RegisterEffect(e3x)
	local e3y=Effect.CreateEffect(c)
	e3y:SetType(EFFECT_TYPE_FIELD)
	e3y:SetRange(LOCATION_MZONE)
	e3y:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3y:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3y:SetTargetRange(0,1)
	e3y:SetLabelObject(e3x)
	e3y:SetCondition(c500316971.sumlimcon)
	e3y:SetTarget(c500316971.sumlimit)
	c:RegisterEffect(e3y)
	--register non-Evolute Spsummon
	local e4x=Effect.CreateEffect(c)
	e4x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4x:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4x:SetRange(LOCATION_MZONE)
	e4x:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4x:SetLabelObject(e3x)
	e4x:SetCondition(c500316971.ctcon)
	e4x:SetOperation(c500316971.ctop)
	c:RegisterEffect(e4x)
	local e4y=Effect.CreateEffect(c)
	e4y:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4y:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4y:SetRange(LOCATION_MZONE)
	e4y:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4y:SetLabelObject(e3y)
	e4y:SetCondition(c500316971.ctcon2)
	e4y:SetOperation(c500316971.ctop)
	c:RegisterEffect(e4y)
	--reset labels
	local reset=Effect.CreateEffect(c)
	reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	reset:SetRange(LOCATION_MZONE+LOCATION_SZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_OVERLAY)
	reset:SetCode(EVENT_TURN_END)
	reset:SetCountLimit(1)
	reset:SetLabelObject(e3y)
	reset:SetCondition(c500316971.resetcon)
	reset:SetOperation(c500316971.resetop)
	c:RegisterEffect(reset)
end
--filters
function c500316971.filter1(c,ec,tp)
	return c:IsType(TYPE_RITUAL) and (c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_EARTH))
end
function c500316971.xfilter(c,tp)
	return c:IsSetCard(0x185a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()  --and Duel.IsExistingMatchingCard(c500316971.xfilter2,tp,LOCATION_DECK,0,1,nil,c)
	 
end
function c500316971.xfilter2(c,mc)
	 return c:IsSetCard(0x85a) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c500316971.xfilter3(c)
	return c:IsLocation(LOCATION_HAND) and c:IsType(TYPE_RITUAL)
end
function c500316971.ctfilter(c,tp)
	return c:IsFaceup() and not c:IsType(TYPE_EVOLUTE) and c:GetSummonLocation()==LOCATION_EXTRA and c:GetSummonPlayer()==tp
end
function c500316971.ctfilter2(c,tp)
	return c:IsFaceup() and not c:IsType(TYPE_EVOLUTE) and c:GetSummonLocation()==LOCATION_EXTRA and c:GetSummonPlayer()~=tp
end
-----
function c500316971.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function c500316971.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c500316971.xfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function c500316971.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c500316971.xfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c500316971.xfilter2),tp,LOCATION_DECK,0,nil,g:GetFirst())
		if mg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			if g:IsExists(c500316971.xfilter3,1,nil) and Duel.IsPlayerCanDraw(tp,1) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
--spsummon limit
function c500316971.sumlimcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==123
end
function c500316971.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_EVOLUTE)
end
--register non-Evolute spsummon
function c500316971.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c500316971.ctfilter,1,nil,tp)
end
function c500316971.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c500316971.ctfilter2,1,nil,tp)
end
function c500316971.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(123)
end
--reset labels
function c500316971.resetcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==123 or e:GetLabelObject():GetLabelObject():GetLabel()==123
end
function c500316971.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
	e:GetLabelObject():GetLabelObject():SetLabel(0)
	if e:GetLabelObject():GetLabel()==0 and e:GetLabelObject():GetLabelObject():GetLabel()==0 then
		Debug.Message('Labels resetted successfully')
	end
end