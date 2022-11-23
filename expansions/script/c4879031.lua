--Crisi Artiglio Nero Pece - Vacuità
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEASTWARRIOR),4,2)
	--protection
	c:EffectProtection()
	--search
	c:SummonedTrigger(false,false,true,false,0,CATEGORIES_SEARCH,true,true,
		aux.XyzSummonedCond,
		nil,
		aux.SearchTarget(s.thfilter),
		s.thop
	)
	--equip
	local ign=c:Ignition(2,CATEGORY_DESTROY+CATEGORY_EQUIP,EFFECT_FLAG_CARD_TARGET,LOCATION_MZONE,true,
		nil,
		aux.DetachSelfCost(),
		s.eqtg,
		s.eqop,
		nil,
		s.quickcon
	)
end
function s.thfilter(c)
	return c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.efilter(e,re)
	return re:GetActiveType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and not re:GetHandler():IsSetCard(0x571)
end

function s.eqfilter(c,tp)
	return c:IsFaceup() and c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP
end
function s.eqfilter2(c,tp,cc)
	return c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and c:IsSetCard(0x571)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden() and c:CheckEquipTarget(cc)
end
function s.eqtcfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_DECK,0,1,nil,tp,c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	local eqc=g1:GetFirst()
	e:SetLabelObject(eqc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local dc=e:GetLabelObject()
	if dc and dc:IsRelateToChain() and Duel.Destroy(dc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local g=Duel.GetTargetCards()
		if #g==0 then return end
		local tc=g:GetFirst()
		if tc==dc and #g>1 then tc=g:GetNext() end
		if tc and s.eqtcfilter(tc,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			local ec=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_DECK,0,1,1,nil,tp,tc):GetFirst()
			if ec then
				Duel.Equip(tp,ec,tc)
			end
		end
	end
end

function s.quickcon(e,tp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x571)
end