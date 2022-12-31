--MMS - Razziatore
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--search
	c:SummonedTrigger(false,true,true,false,0,CATEGORY_SEARCH+CATEGORY_TOHAND,EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET,{true,true},
		nil,
		nil,
		aux.ExcavateTarget(5),
		aux.ExcavateOperation(CONJUNCTION_AND_IF_YOU_DO_YOU_CAN,
								aux.MonsterFilter(Card.IsSetCard,0xd71),
								1,
								nil,
								CONJUNCTION_THEN,
								SEQ_DECKTOP,
								id,
								1
							 )
	)
	--draw
	c:Ignition(2,CATEGORY_TOGRAVE,EFFECT_FLAG_CARD_TARGET,LOCATION_GRAVE,{true,true},
		nil,
		aux.bfgcost,
		aux.Target(s.rtfilter,LOCATION_REMOVED,0,3,3,nil,s.check,CATEGORY_TOGRAVE,nil,nil,aux.DrawInfo(0,1)),
		aux.CreateOperation(
			aux.ReturnToGYOperation(SUBJECT_THEM),
			CONJUNCTION_THEN,
			aux.DrawOperation(1)
		)
	)
end
function s.thfilter(c)
	return (c:IsSetCard(0xd71) and c:IsST(TYPE_CONTINUOUS)) or c:IsCode(19905912)
end

function s.drawcon(e)
	return not e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetLabel(p)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,p)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.splimit(e,c)
	local p=e:GetLabel()
	return c:IsLocation(LOCATION_EXTRA) and c:IsControler(p) and not c:IsSetCard(0xd71)
end

function s.check(e,tp)
	return Duel.IsPlayerCanDraw(tp,1)
end
function s.rtfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0xd71) and not c:IsCode(id)
end