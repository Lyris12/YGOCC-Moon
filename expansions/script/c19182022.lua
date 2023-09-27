--Flaircaster Vector
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--atk
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES|CATEGORY_TOGRAVE)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:HOPT(true)
	e0:SetCost(s.cost)
	e0:SetTarget(s.ptg)
	e0:SetOperation(s.pop)
	c:RegisterEffect(e0)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	--excavate
	local ex=aux.AddAircasterExcavateEffect(c,3,EFFECT_TYPE_QUICK_O,1,ARCHE_FLAIRCASTER,e2,CATEGORY_SPECIAL_SUMMON)
	e2:SetLabelObject(ex)
	--equip
	aux.AddAircasterEquipEffect(c,3)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:Desc(4)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.econ)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
function s.csfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AIRCASTER) and c:IsAbleToDeckAsCost()
end
function s.gcheck(g,tp)
	return g:IsExists(Card.IsPendulumMonsterCard,1,nil) and Duel.GetMZoneCount(tp,g)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.csfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3,tp)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.spfilter(c,e,tp)
	if not (c:IsSetCard(ARCHE_AIRCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	local lv
	local list=c:GetRating()
	for i=1,3 do
		local rating=list[i]
		if type(rating)=="number" then
			lv=rating
			break
		end
	end
	return lv and lv>0 and Duel.IsPlayerCanDiscardDeck(tp,lv)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and Duel.IsPlayerCanSendtoGrave(tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local lv
		local list=tc:GetRating()
		for i=1,3 do
			local rating=list[i]
			if type(rating)=="number" then
				lv=rating
				break
			end
		end
		if not lv then return end
		Duel.ConfirmDecktop(tp,lv)
		local dg=Duel.GetDecktopGroup(tp,lv)
		local sg=dg:Filter(aux.AircasterExcavateFilter,nil)
		if #sg>0 then
			Duel.DisableShuffleCheck()
			Duel.SendtoGrave(sg,REASON_EFFECT|REASON_EXCAVATE)
		end
		Duel.ShuffleDeck(tp)
	end
end

function s.cfilter(c,eid,e)
	local re=c:GetReasonEffect()
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) and re and re==e and re:GetFieldID()==eid
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local eid=e:GetLabel()
	if not eid then return false end
	return eg:IsExists(s.cfilter,1,nil,eid,e:GetLabelObject())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.econ(e,tp)
	local c=e:GetHandler()
	if not c:IsSpell(TYPE_EQUIP) then return false end
	local eqc=c:GetEquipTarget()
	if not eqc then return false end
	local bc=eqc:GetBattleTarget()
	return bc and eqc:IsRelateToBattle() and bc:IsRelateToBattle() and bc:IsControler(1-tp)
end
function s.filter(c,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(ARCHE_AIRCASTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local eqc=e:GetHandler():GetEquipTarget()
	if not eqc or not eqc:IsFaceup() then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,nil,tp)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,5)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,eqc)
	end
end