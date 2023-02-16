--Protosdragia, la Vita Originaria
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--redirect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)
	--ss
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetLabel(0)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
end

--redirect
function s.cfilter(c,loc)
	local t={[LOCATION_REMOVED]=Card.IsAbleToRemoveAsCost; [LOCATION_HAND]=Card.IsAbleToHandAsCost; [LOCATION_DECK]=Card.IsAbleToDeckOrExtraAsCost}
	return type(t[loc])=="function" and t[loc](c)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=c:GetDestination()
	if chk==0 then
		return (r&REASON_EFFECT)~=0 and not c:IsReason(REASON_REPLACE) and rp~=tp and loc&(LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,loc)
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,loc)
		if #g>0 then
			if loc==LOCATION_REMOVED then
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
			elseif loc==LOCATION_HAND then
				Duel.SendtoHand(g,nil,REASON_EFFECT+REASON_REPLACE)
			elseif loc==LOCATION_DECK then
				Duel.SendtoDeck(g,nil,2,REASON_EFFECT+REASON_REPLACE)
			else
				return false
			end
		end
		return true
	else
		return false
	end
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==tp and (c:IsReason(REASON_BATTLE) and c:IsReason(REASON_DESTROY) or c:IsReason(REASON_EFFECT) and rp~=tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():GetReasonCard() or e:GetHandler():IsReason(REASON_EFFECT) and re:GetHandler()
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(rc:GetOriginalType(),rc:GetOriginalAttribute(),rc:GetOriginalRace(),rc:GetTextAttack(),rc:GetTextDefense())
end

function s.condition(e)
	return e:GetHandler():HasFlagEffect(id)
end
function s.filter(c,e,tp,list)
	local typ,attr,rc,atk,def=table.unpack(list)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local exft=Duel.GetLocationCountFromEx(tp,tp,nil,c)
	local emzft=Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)
	return typ&TYPE_MONSTER>0 and c:IsMonster() and (c:IsLocation(LOCATION_DECK) and ft>1 or c:IsLocation(LOCATION_EXTRA) and (ft>1 and exft>0 or ft<=1 and emzft>0))
	and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and (c:GetOriginalAttribute()&attr>0 or c:GetOriginalRace()&rc>0 or c:GetTextAttack()==atk or c:GetTextDefense()==def) and not c:IsCode(id)
		or typ&TYPE_SPELL>0 and c:IsLocation(LOCATION_DECK) and c:IsType(TYPE_SPELL) and (typ&TYPE_CONTINUOUS+TYPE_FIELD+TYPE_RITUAL+TYPE_EQUIP+TYPE_QUICKPLAY==0
		and c:GetType()==TYPE_SPELL or c:IsType(typ&TYPE_CONTINUOUS+TYPE_FIELD+TYPE_RITUAL+TYPE_EQUIP+TYPE_QUICKPLAY)) and c:IsAbleToHand()
			or typ&TYPE_TRAP>0 and c:IsLocation(LOCATION_DECK) and c:IsType(TYPE_TRAP) and (typ&TYPE_CONTINUOUS+TYPE_COUNTER==0 and c:GetType()==TYPE_TRAP or c:IsType(typ&TYPE_CONTINUOUS+TYPE_COUNTER)) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,{e:GetLabel()})
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,{e:GetLabel()})
		if #g>0 then
			local tc=g:GetFirst()
			local typ=tc:GetOriginalType()
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local exft=Duel.GetLocationCountFromEx(tp,tp,nil,tc)
			local ogtyp,attr,rc,atk,def=e:GetLabel()
			--
			local b1=typ&TYPE_MONSTER>0 and (tc:IsLocation(LOCATION_DECK) and ft>0 or tc:IsLocation(LOCATION_EXTRA) and exft>0) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (tc:GetOriginalAttribute()&attr>0 or tc:GetOriginalRace()&rc>0 or tc:GetTextAttack()==atk or tc:GetTextDefense()==def)
			and not tc:IsCode(id)
			local b2=typ&TYPE_SPELL>0 and tc:IsLocation(LOCATION_DECK)
			and (ogtyp&TYPE_CONTINUOUS+TYPE_FIELD+TYPE_RITUAL+TYPE_EQUIP+TYPE_QUICKPLAY==0 and tc:GetType()==TYPE_SPELL or tc:IsType(ogtyp&TYPE_CONTINUOUS+TYPE_FIELD+TYPE_RITUAL+TYPE_EQUIP+TYPE_QUICKPLAY)) and tc:IsAbleToHand()
			local b3=typ&TYPE_TRAP>0 and tc:IsLocation(LOCATION_DECK) and (ogtyp&TYPE_CONTINUOUS+TYPE_COUNTER==0 and tc:GetType()==TYPE_TRAP or tc:IsType(ogtyp&TYPE_CONTINUOUS+TYPE_COUNTER)) and tc:IsSSetable()
			local b={b1,b2,b3}
			local off=1
			local ops={}
			local opval={}
			for i=0,#b-1 do
				if b[i+1] then
					ops[off]=aux.Stringid(id,2+i)
					opval[off]=i
					off=off+1
				end
			end
			local op=Duel.SelectOption(tp,table.unpack(ops))+1
			local sel=opval[op]
			e:SetLabel(sel)
			Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,sel+2))
			if sel==0 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			elseif sel==1 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			elseif sel==2 then
				Duel.SSet(tp,tc)
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
end